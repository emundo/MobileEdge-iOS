/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This file is part of MobileEdge-iOS.
 * MobileEdge-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileEdge-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MobileEdge-iOS.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created by Raphael Arias on 8/07/14.
 */

#import "MOBAxolotl.h"
#import "MOBAxolotlSession.h"
#import "MOBAxolotlChainKey.h"
#import "MOBAxolotlSkippedKeyRing.h"
#import "MOBIdentity.h"
#import "MOBRemoteIdentity.h"
#import "MOBCore.h"
#import "NACLKey+ScalarMult.h"
#import "NACLKey+Base64.h"
#import "HKDFKit+Strings.h"
#import <HKDFKit.h>
#import <SodiumObjc.h>
#import <sodium/crypto_hash.h>
#import <sodium/crypto_auth_hmacsha256.h>
#import <FXKeychain.h>

static NSMutableDictionary *cachedAxolotls = nil;
#pragma mark -
#pragma mark Class Extension

@interface MOBAxolotl ()

@property (nonatomic,strong) MOBIdentity *identity;
@property (nonatomic,strong) FXKeychain *keychain;
@property (nonatomic,strong) NSMutableDictionary *sessions;
@property (nonatomic,assign) BOOL appendEncryptedSenderInformation;

- (void) addSession: (MOBAxolotlSession *) aSession
          forRemote: (MOBRemoteIdentity *) aBobIdentity;

@end

#pragma mark -
#pragma mark Implementation

@implementation MOBAxolotl

+ (instancetype) cachedProtocolForIdentity: (MOBIdentity *) identity
{
    MOBAxolotl *axolotl = nil;
    if (!cachedAxolotls)
    {
        cachedAxolotls = [NSMutableDictionary dictionaryWithObject: [[MOBAxolotl alloc] initWithIdentity: identity]
                                                            forKey: [identity base64]];
    }
    if (!(axolotl = cachedAxolotls[[identity base64]]))
    {
        cachedAxolotls[[identity base64]] = [[MOBAxolotl alloc] initWithIdentity: identity];
    }
    return cachedAxolotls[[identity base64]];
}


- (instancetype) initWithIdentity: (MOBIdentity *) aIdentity
{
    if (self = [super init])
    {
        self.identity = aIdentity;
        self.keychain = [[FXKeychain alloc] initWithService: @"MobileEdgeAxolotl"
                                                accessGroup: @"MobileEdgeAxolotl"
                                              accessibility: FXKeychainAccessibleAfterFirstUnlock];
        self.sessions = self.keychain[[self.identity.identityKey base64]];
        self.appendEncryptedSenderInformation = YES;
    }
    return self;
}


#pragma mark -
#pragma mark Encryption
- (NSDictionary *) encryptString: (NSString *) aMessage
                    forRecipient: (MOBRemoteIdentity *) aReceiver
                           error: (NSError **) aError
{
    return [self encryptData: [aMessage dataUsingEncoding: NSUTF8StringEncoding]
                forRecipient: aReceiver
                       error: aError];
}

- (NSDictionary *) encryptData: (NSData *) aData
                  forRecipient: (MOBRemoteIdentity *) aRecipient
                         error: (NSError **) aError
{
    MOBAxolotlSession *session;
    if (!(session = (MOBAxolotlSession *) (self.sessions[[aRecipient base64]])))
    { // fail! we dont have a session for the given remote!
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolNoSessionForRemote];
        return nil;
    }
    
    if (session.ratchetFlag)
    { // ratchet the key material:
        [session ratchetStateBeforeSending];
    }
    
    // Derive a new message key from chain key":
    DDLogDebug(@"Deriving key from chain key: \n%@", session.senderChainKey.data);
    NACLSymmetricPrivateKey *messageKey = [session.senderChainKey nextMessageKey];
    
    // generate nonces:
    NACLNonce *nonce1 = [NACLNonce nonce];
    NACLNonce *nonce2 = [NACLNonce nonce];
    
    // encrypt Axolotl body:
    NSData *encryptedBody = [aData encryptedDataUsingPrivateKey: messageKey
                                                           nonce: nonce1
                                                           error: nil]; // TODO: error handling
    
    DDLogDebug(@"Encrypted message with key: \n%@\nfor Identity: %@", messageKey.data, [aRecipient base64]);
    // encrypt Axolotl header:
    NSArray *header = [NSArray arrayWithObjects:
                       [NSNumber numberWithUnsignedInteger: session.messagesSentCount],
                       [NSNumber numberWithUnsignedInteger: session.messagesSentUnderPreviousRatchetCount],
                       [session.senderDiffieHellmanKey.publicKey.data base64EncodedStringWithOptions: 0],
                       nil];
    NSData *headerData = [NSJSONSerialization dataWithJSONObject: header
                                                         options: 0
                                                           error: nil]; // TODO: error handling
    NSData *encryptedHeader = [headerData encryptedDataUsingPrivateKey: session.senderHeaderKey
                                                                  nonce: nonce2
                                                                   error: nil]; // TODO: error handling
    // pack message:
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary: @{ @"v" : @"0.1",
                                      @"head" : [encryptedHeader base64EncodedStringWithOptions: 0],
                                      @"body" : [encryptedBody base64EncodedStringWithOptions: 0] }];
    if (self.appendEncryptedSenderInformation)
    {
        NACLNonce *pubKeyNonce = [NACLNonce nonce];
        NACLAsymmetricKeyPair *ephKeyPair = [NACLAsymmetricKeyPair keyPair];
        NSData *diffieHellmanData = [ephKeyPair.privateKey multWithKey: aRecipient.identityKey].data;
        NACLSymmetricPrivateKey *pubKeyEncryptionKey =
        [[NACLSymmetricPrivateKey alloc] initWithData: [HKDFKit deriveKey: diffieHellmanData
                                                               infoString: @"MobileEdge PubKeyEncrypt"
                                                               saltString: @"salty"
                                                               outputSize: [NACLSymmetricPrivateKey keyLength]]]; //FIXME: int conversion?
        NSData *encryptedPubKeyData =
            [self.identity.identityKey.data encryptedDataUsingPrivateKey: pubKeyEncryptionKey
                                                                    nonce: pubKeyNonce
                                                                    error: nil];
        message[@"eph"] = [ephKeyPair.publicKey.data base64EncodedStringWithOptions: 0];
        message[@"from"] = [encryptedPubKeyData base64EncodedStringWithOptions: 0];
    }
    // advance session state:
    [session advanceStateAfterSending];
    
    return message;
}

#pragma mark -
#pragma mark Decryption

- (NSArray *) decryptAndParseHeader: (NSString *) aBase64Header
                            withKey: (NACLSymmetricPrivateKey *) aHeaderKey
{
    NSData *headerData = [[NSData alloc] initWithBase64EncodedString: aBase64Header
                                                             options: 0];
    NSData *decryptedHeader;
    if (!(decryptedHeader = [headerData decryptedDataUsingPrivateKey: aHeaderKey
                                                               error: nil]))
    { // Decryption of the header failed.
        return nil;
    }

    id parsedHeaderObject = [NSJSONSerialization JSONObjectWithData: decryptedHeader
                                                            options: 0
                                                              error: nil];
    if (!parsedHeaderObject
        || ![parsedHeaderObject isKindOfClass: [NSArray class]]
        || ([parsedHeaderObject count] != 3))
    { // Header format invalid.
        return nil;
    }
    
    return parsedHeaderObject;
}

- (NSData *) attemptDecryptionWithSkippedKeys: (NSMutableArray *) aSkippedKeys
                                   forMessage: (NSDictionary *) aEncryptedMessage
{
    NSData *decryptedMessageBody;
    for (MOBAxolotlSkippedKeyRing *keyRing in aSkippedKeys)
    {
        // attempt decryption of header:
        NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                    withKey: keyRing.headerKey];
        if (!parsedHeader)
        {
            continue;
        }
        NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                      options: 0];
        for (NACLSymmetricPrivateKey *messageKey in keyRing.messageKeys) {
            // attempt decryption:
            if ((decryptedMessageBody = [messageBodyData decryptedDataUsingPrivateKey: messageKey
                                                                                error: nil]))
            { // Decryption successful.
                // delete message key from array:
                [keyRing.messageKeys removeObject: messageKey];
                // TODO: could there be performance gain when deleting by index rather than object?
                if (0 == keyRing.messageKeys.count)
                { // header key can be removed as well:
                    [aSkippedKeys removeObject: keyRing];
                }
                return decryptedMessageBody;
            }
        }
    }
    return nil;
}

- (void) stageSkippedKeysInSession: (MOBAxolotlSession *) aSession
              currentMessageNumber: (NSUInteger) aCurrentMessageNumber
               futureMessageNumber: (NSUInteger) aFutureMessageNumber
             usingSpecialHeaderKey: (NACLSymmetricPrivateKey *) aHeaderKey
              usingSpecialChainKey: (MOBAxolotlChainKey *) aChainKey
                             error: (NSError **) aError
{
    MOBAxolotlChainKey *chainKey = (aChainKey) ? aChainKey : aSession.receiverChainKey;
    NACLSymmetricPrivateKey *headerKey = (aHeaderKey) ? aHeaderKey : aSession.receiverHeaderKey;
    // TODO: check what TS does here with chainkey.index > counter
    if (aFutureMessageNumber - aCurrentMessageNumber > 500)
    { // more than 500 skipped messages (same number TextSecure sets as limit)
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBAxolotlExceedingSkippedMessageLimit];
        return;
    }
    
    NSMutableArray *messageKeys = [NSMutableArray arrayWithCapacity: aFutureMessageNumber - aCurrentMessageNumber];
    NACLSymmetricPrivateKey *messageKey;
    for (NSUInteger i = aCurrentMessageNumber; i < aFutureMessageNumber; i++) {
        messageKey = [chainKey nextMessageKey];
        [messageKeys addObject: messageKey];
    }
    [aSession stageMessageKeys: messageKeys forHeaderKey: headerKey];
    messageKey = [chainKey nextMessageKey];
    aSession.currentMessageKey = messageKey;
    aSession.purportedReceiverChainKey = chainKey;
}

- (NSData *) attemptDecryptionUsingCurrentHeaderKeyWithSessionState: (MOBAxolotlSession *) aSession
                                                         forMessage: (NSDictionary *) aEncryptedMessage
                                                              error: (NSError **) aError
{
    // attempt to decrypt header with receiverHeaderKey:
    NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                withKey: aSession.receiverHeaderKey];
    if (!parsedHeader)
    { // TODO: error handling
        return nil;
    }
    
    [self stageSkippedKeysInSession: aSession
               currentMessageNumber: aSession.messagesReceivedCount
                futureMessageNumber: [((NSNumber *) parsedHeader[0]) unsignedIntegerValue]
              usingSpecialHeaderKey: nil
               usingSpecialChainKey: nil
                              error: aError]; // passing nil just takes the one from the session.
    
    NACLSymmetricPrivateKey *messageKey = aSession.currentMessageKey;
    
    // attempt to decrypt message body:
    NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                  options: 0];
    NSData *decryptedMessage;
    if (!(decryptedMessage = [messageBodyData decryptedDataUsingPrivateKey: messageKey
                                                                     error: nil]))
    { // Decryption failed. Do something here. TODO!
        DDLogError(@"Error while decrypting with existing chain. Header key matches but message key does not.");
        // Do we set an error object?
        return nil;
    }
    
    // If we get here, it means we successfully decrypted the message and we can hand it back:
    return decryptedMessage;
}

- (NSData *) deriveKeyDataWithRootKey: (NSData *) aRootKey
                         ourEphemeral: (NACLAsymmetricPrivateKey *) aOurEphemeral
                       theirEphemeral: (NACLAsymmetricPublicKey *) aTheirEphemeral
{
    NSData *diffieHellman = [aOurEphemeral multWithKey: aTheirEphemeral].data;
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithLength: (256 / 8)];
    crypto_auth_hmacsha256(inputKeyMaterial.mutableBytes,
                           diffieHellman.bytes,
                           [diffieHellman length],
                           aRootKey.bytes);
    return [HKDFKit deriveKey: inputKeyMaterial
                   infoString: @"MobileEdge Ratchet"
                   saltString: @"salty"
                   outputSize: 3*32];
}

- (NSData *) attemptDecryptionUsingNextHeaderKeyWithSessionState: (MOBAxolotlSession *) aSession
                                                      forMessage: (NSDictionary *) aEncryptedMessage
                                                           error: (NSError **) aError
{
    NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                withKey: aSession.receiverNextHeaderKey];
    if (!parsedHeader)
    {
        return nil;
    }
    if (aSession.receiverHeaderKey)
    { // there is a previous ratchet.
        // stage skipped keys for last ratchet:
        [self stageSkippedKeysInSession: aSession
                   currentMessageNumber: aSession.messagesReceivedCount
                    futureMessageNumber: [((NSNumber *) parsedHeader[1]) unsignedIntegerValue]
                  usingSpecialHeaderKey: nil
                   usingSpecialChainKey: nil
                                  error: aError];
    }
    NACLSymmetricPrivateKey *purportedHeaderKey = aSession.receiverNextHeaderKey;
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString: ((NSString *) parsedHeader[2])
                                                          options: 0];
    NACLAsymmetricPublicKey *theirEphemeralKey = [[NACLAsymmetricPublicKey alloc] initWithData: keyData];
    // derive new key material from ratchet keys in state and message:
    NSData *derivedKeyMaterial = [self deriveKeyDataWithRootKey: aSession.rootKey
                                                   ourEphemeral: aSession.senderDiffieHellmanKey.privateKey
                                                 theirEphemeral: theirEphemeralKey];
    NSData *purportedRootKey = [derivedKeyMaterial subdataWithRange: NSMakeRange(0, 32)];
    NACLSymmetricPrivateKey *purportedReceiverNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                                                               [derivedKeyMaterial subdataWithRange: NSMakeRange(1*32, 32)]];
    MOBAxolotlChainKey *purportedReceiverChainKey = [[MOBAxolotlChainKey alloc] initWithKeyData:
                                                     [derivedKeyMaterial subdataWithRange: NSMakeRange(2*32, 32)]];
    // stage skipped keys for this ratchet:
    [self stageSkippedKeysInSession: aSession
               currentMessageNumber: 0
                futureMessageNumber: [((NSNumber *) parsedHeader[0]) unsignedIntegerValue]
              usingSpecialHeaderKey: purportedHeaderKey //purportedReceiverNextHeaderKey
               usingSpecialChainKey: purportedReceiverChainKey
                              error: aError];
  
    // Attempt decrypting message body:
    NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                  options: 0];
    NSData *decryptedMessageBody = [messageBodyData decryptedDataUsingPrivateKey: aSession.currentMessageKey
                                                                           error: nil];
    if (!decryptedMessageBody)
    { // Decryption failed (again).
        return nil;
    }
    
    // set new values/keys in state, erase DH key pair and set ratchet flag:
    NACLAsymmetricPublicKey *parsedDiffieHellmanKey =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: parsedHeader[2]
                                             options: 0]];
    [aSession ratchetStateAfterReceivingRootKey: purportedRootKey
                                  nextHeaderKey: purportedReceiverNextHeaderKey
                               diffieHellmanKey: parsedDiffieHellmanKey];
    
    return decryptedMessageBody;
}

- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                 fromSender: (MOBRemoteIdentity *) aSender
                      error: (NSError **) aError
{
    MOBAxolotlSession *session;
    if (!(session = self.sessions[[aSender base64]]))
    { // fail! we dont have a session for the given remote!
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolNoSessionForRemote];
        return nil;
    }
    
    NSData *decryptedMessage;
    
    // try decrypting with skipped header and message keys:
    if ((decryptedMessage = [self attemptDecryptionWithSkippedKeys: session.skippedHeaderAndMessageKeys
                                                        forMessage: aEncryptedMessage]))
    { // Decryption successful.
        return decryptedMessage;
    }
    // try decrypting with current header key:
    if ((session.receiverHeaderKey) &&
        (decryptedMessage = [self attemptDecryptionUsingCurrentHeaderKeyWithSessionState: session //TODO! // What exactly? :(
                                                                              forMessage: aEncryptedMessage
                                                                                   error: aError]))
    { // Decryption successful.
        [session advanceStateAfterReceiving];
        return decryptedMessage;
    }
    
    // So far, decryption has _not_ been successful. Advance the state and retry:
    if (session.ratchetFlag)
    { // Ratchet flag is set.
        // This should not be if the message was undecryptable with current header key
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBAxolotlRatchetFlagSetUnexpectedly];
        return nil;
    }
    if (!(decryptedMessage = [self attemptDecryptionUsingNextHeaderKeyWithSessionState: session
                                                                            forMessage: aEncryptedMessage
                                                                                 error: aError]))
    { // Last decryption attempt has failed. Cannot decrypt.
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolMessageDecryptionFailed];
        return nil;
    }
    // Decryption successful!
    // increase number of received messages, update chain key, commit staged keys:
    [session advanceStateAfterReceiving];
    
    // return decrypted message:
    return decryptedMessage;
}

- (NSString *) decryptedStringFromMessage: (NSDictionary *) aEncryptedMessage
                               fromSender: (MOBRemoteIdentity *) aSender
                                    error: (NSError **) aError
{
    return [[NSString alloc] initWithData: [self decryptMessage: aEncryptedMessage
                                                     fromSender: aSender
                                                          error: aError]
                                 encoding: NSUTF8StringEncoding];
}

- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                      error: (NSError **) aError
{
    if (!aEncryptedMessage[@"from"]
        || !aEncryptedMessage[@"eph"])
    { // We cannot decrypt a message without information about the sender:
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolNoSenderInformation];
        return nil;
    }
    NSData *encryptedSenderData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"from"]
                                                                      options: 0];
    NSData *ephPubData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"eph"]
                                                             options: 0];
    NACLAsymmetricPublicKey *ephPubKey = [[NACLAsymmetricPublicKey alloc] initWithData: ephPubData];
    NSData *diffieHellmanData = [self.identity.identityKeyPair.privateKey multWithKey: ephPubKey].data;

    NACLSymmetricPrivateKey *pubKeyCipher =
        [[NACLSymmetricPrivateKey alloc] initWithData: [HKDFKit deriveKey: diffieHellmanData
                                                               infoString: @"MobileEdge PubKeyEncrypt"
                                                               saltString: @"salty"
                                                               outputSize: [NACLSymmetricPrivateKey keyLength]]]; //FIXME: int conversion?
    NSData *decryptedSenderData = [encryptedSenderData decryptedDataUsingPrivateKey: pubKeyCipher
                                                                              error: nil];
    if (!decryptedSenderData)
    { // Could not decrypt the sender information. It was incomplete or incorrect.
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolIncorrectSenderInformation];
        return nil;
    }
    NACLAsymmetricPublicKey *senderIdentityKey =
        [[NACLAsymmetricPublicKey alloc] initWithData: decryptedSenderData];
    MOBRemoteIdentity *senderIdentity = [[MOBRemoteIdentity alloc] initWithPublicKey: senderIdentityKey];
    return [self decryptMessage: aEncryptedMessage fromSender: senderIdentity error: aError];
}

#pragma mark -
#pragma mark Key exchange
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) aSendKeyExchangeBlock
                             error: (NSError **) aError
{
    NACLAsymmetricKeyPair *myEphemeralKeyPair = [NACLAsymmetricKeyPair keyPair];
    NSMutableDictionary *keyExchangeMessageOut = [NSMutableDictionary dictionary];
    
    [keyExchangeMessageOut setObject:[self.identity.identityKey.data base64EncodedStringWithOptions: 0] forKey:@"id"];
    [keyExchangeMessageOut setObject:[myEphemeralKeyPair.publicKey.data base64EncodedStringWithOptions: 0] forKey:@"eph0"];
    KeyExchangeFinalizeBlock finalizeBlock;
    finalizeBlock = ^(NSDictionary *keyExchangeMessageIn)
    {
        MOBAxolotlSession *newSession = [[MOBAxolotlSession alloc] initWithMyIdentityKeyPair: self.identity.identityKeyPair
                                                                            theirIdentityKey: aBob.identityKey];
        [newSession finishKeyAgreementWithKeyExchangeMessage: keyExchangeMessageIn
                                          myEphemeralKeyPair: myEphemeralKeyPair];
        [self addSession:newSession forRemote:aBob];
        [self.keychain setObject: self.sessions
                          forKey: [self.identity.identityKey base64]];
    };
    if ([NSJSONSerialization isValidJSONObject: keyExchangeMessageOut])
    {
        aSendKeyExchangeBlock(keyExchangeMessageOut, finalizeBlock);
    }
    else
    { // TODO: error handling
        DDLogError(@"Could not generate a valid JSON key exchange message.");
    }
}

- (void) performKeyExchangeWithAlice: (MOBRemoteIdentity *) aAlice
             usingKeyExchangeMessage: (NSData *) aTheirKeyExchangeMessage
      andSendKeyExchangeMessageUsing: (KeyExchangeSendBlockBob) aSendKeyExchangeBlock
                               error: (NSError **) aError
{
    // When we are Bob we need two ephemeral keys:
    NACLAsymmetricKeyPair *myEphemeralKeyPair0 = [NACLAsymmetricKeyPair keyPair];
    NACLAsymmetricKeyPair *myEphemeralKeyPair1 = [NACLAsymmetricKeyPair keyPair];
    NSMutableDictionary *keyExchangeMessageOut = [NSMutableDictionary dictionary];
    
    [keyExchangeMessageOut setObject: [self.identity.identityKey.data base64EncodedStringWithOptions: 0] forKey: @"id"];
    [keyExchangeMessageOut setObject: [myEphemeralKeyPair0.publicKey.data base64EncodedStringWithOptions: 0] forKey: @"eph0"];
    [keyExchangeMessageOut setObject: [myEphemeralKeyPair1.publicKey.data base64EncodedStringWithOptions: 0] forKey: @"eph1"];
    
    MOBAxolotlSession *newSession = [[MOBAxolotlSession alloc] initWithMyIdentityKeyPair: self.identity.identityKeyPair
                                                                        theirIdentityKey: aAlice.identityKey];
    NSDictionary *keyExchangeMessageIn = [NSJSONSerialization JSONObjectWithData: aTheirKeyExchangeMessage
                                                                         options: 0
                                                                           error: nil]; // TODO: error / conversion might already have been handled!
    if (![keyExchangeMessageIn isKindOfClass: [NSDictionary class]])
    { // Error while interpreting key exchange message
        [MOBError populateErrorObject: aError
                            forDomain: kMOBErrorDomainProtocol
                            errorCode: kMOBProtocolKeyExchangeMessageInvalid];
        DDLogError(@"Error while interpreting Alice's key exchange message. %@", aTheirKeyExchangeMessage);
        return;
    }
    [newSession finishKeyAgreementWithAliceWithKeyExchangeMessage: keyExchangeMessageIn
                                              myEphemeralKeyPair0: myEphemeralKeyPair0
                                              myEphemeralKeyPair1: myEphemeralKeyPair1];
    [self addSession: newSession forRemote: aAlice];
    [self.keychain setObject: self.sessions
                      forKey: [self.identity.identityKey base64]];
    
    if ([NSJSONSerialization isValidJSONObject: keyExchangeMessageOut])
    {
        //aSendKeyExchangeBlock([NSJSONSerialization dataWithJSONObject: keyExchangeMessageOut options:0 error: nil], finalizeBlock);   //TODO: error
        aSendKeyExchangeBlock(keyExchangeMessageOut);
    }
    else
    { // TODO: error handling
        DDLogError(@"Could not generate a valid JSON key exchange message.");
    }
}

#pragma mark -
#pragma mark Session management

- (BOOL) hasSessionForRemote: (MOBRemoteIdentity *) aBob
{
    if (!self.sessions)
    {
        return NO;
    }
    if ([self.sessions objectForKey: [aBob base64]])
    {
        return YES;
    }
    return NO;
}

- (void) addSession: (MOBAxolotlSession *) aSession
          forRemote: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (!self.sessions)
    {
        self.sessions = [NSMutableDictionary dictionary];
    }
    [self.sessions setObject: aSession forKey: [aRemoteIdentity base64]];
}

#pragma mark -
#pragma mark Testing functions
#ifdef DEBUG
- (NSData *) getSessionKeyMaterialForTestingForRemote: (MOBRemoteIdentity *) aRemote
{
    if (self.sessions)
    {
        return ((MOBAxolotlSession *) self.sessions[[aRemote base64]]).rootKey;
    }
    return nil;
}
#endif
@end
