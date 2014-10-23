/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo.
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
#import <HKDFKit.h>
#import <SodiumObjc.h>
#import <sodium/crypto_hash.h>
#import <sodium/crypto_auth_hmacsha256.h>
#import <FXKeychain.h>

#pragma mark -
#pragma mark Class Extension

@interface MOBAxolotl ()

@property (nonatomic,strong) MOBIdentity *identity;
@property (nonatomic,strong) FXKeychain *keychain;
@property (nonatomic,strong) NSMutableDictionary *sessions;

- (void) addSession: (MOBAxolotlSession *) aSession
             forBob: (MOBRemoteIdentity *) aBobIdentity;

@end

#pragma mark -
#pragma mark Implementation

@implementation MOBAxolotl

- (instancetype) initWithIdentity: (MOBIdentity *) aIdentity
{
    if (self = [super init])
    {
        self.identity = aIdentity;
        self.keychain = [[FXKeychain alloc] initWithService:@"MobileEdgeAxolotl"
                                                accessGroup:@"MobileEdgeAxolotl"
                                              accessibility:FXKeychainAccessibleAfterFirstUnlock];
        self.sessions = self.keychain[self.identity.identityKey];
    }
    return self;
}


#pragma mark -
#pragma mark Encryption
- (NSString *) encryptMessage: (NSString *) aMessage
                  forRecipient: (MOBRemoteIdentity *) aReceiver
{
#warning stub
    return nil;
}

- (NSDictionary *) encryptData: (NSData *) aData
            forRecipient: (MOBRemoteIdentity *) aRecipient
{
    MOBAxolotlSession *session;
    if (!(session = self.sessions[aRecipient])) {
        // TODO: fail! we dont have a session for the given remote!
    }
    
    // ratchet the key material:
    [session ratchetStateBeforeSending];
    
    // Derive a new message key from chain key":
    NACLSymmetricPrivateKey *messageKey = [session.receiverChainKey nextMessageKey];
    
    // generate nonces:
    NACLNonce *nonce1 = [NACLNonce nonce];
    NACLNonce *nonce2 = [NACLNonce nonce];
    
    // encrypt Axolotl body:
    NSData *encryptedBody = [aData encryptedDataUsingPrivateKey: messageKey
                                                          nonce: nonce1
                                                          error: nil]; // TODO: error handling
    
    // encrypt Axolotl header:
    NSArray *header = [NSArray arrayWithObjects:
                       [NSNumber numberWithUnsignedInteger: session.messagesSentCount],
                       [NSNumber numberWithUnsignedInteger: session.messagesSentUnderPreviousRatchetCount],
                       [session.senderDiffieHellmanKey.publicKey.data base64EncodedStringWithOptions: 0],
                       [nonce1.data base64EncodedStringWithOptions: 0], nil];
    NSData *headerData = [NSJSONSerialization dataWithJSONObject: header
                                                         options: 0
                                                           error: nil]; // TODO: error handling
    NSData *encryptedHeader = [headerData encryptedDataUsingPrivateKey: session.senderHeaderKey
                                                                 nonce: nonce2
                                                                 error: nil]; // TODO: error handling
    // pack message:
    NSDictionary *message = @{ @"nonce" : [nonce2.data base64EncodedStringWithOptions: 0],
                               @"head" : [encryptedHeader base64EncodedStringWithOptions: 0],
                               @"body" : [encryptedBody base64EncodedStringWithOptions: 0] };
    
    // advance session state:
    [session advanceStateAfterSending];
    
    return message;
}

- (NSArray *) decryptAndParseHeader: (NSString *) aBase64Header
                            withKey: (NACLSymmetricPrivateKey *) aHeaderKey
                           andNonce: (NSString *) aBase64Nonce
{
    NSData *headerData = [[NSData alloc] initWithBase64EncodedString: aBase64Header
                                                             options: 0];
    NACLNonce *nonce = [NACLNonce nonceWithData: [[NSData alloc] initWithBase64EncodedString: aBase64Nonce
                                                                                     options: 0]];
    NSData *decryptedHeader;
    if (!(decryptedHeader = [headerData decryptedDataUsingPrivateKey: aHeaderKey
                                                           nonce: nonce
                                                           error: nil]))
    { // Decryption of the header failed.
        return nil;
    }

    id parsedHeaderObject = [NSJSONSerialization JSONObjectWithData: decryptedHeader // TODO: check if valid
                                                            options: 0
                                                              error: nil];
    if ([parsedHeaderObject isKindOfClass: [NSArray class]])
    {
        return parsedHeaderObject;
    }
    
    return nil;
}

- (NSData *) attemptDecryptionWithSkippedKeys: (NSMutableArray *) aSkippedKeys
                                   forMessage: (NSDictionary *) aEncryptedMessage
{
    NSData *decryptedMessageBody;
    for (MOBAxolotlSkippedKeyRing *keyRing in aSkippedKeys)
    {
        // attempt decryption of header:
        NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                    withKey: keyRing.headerKey
                                                   andNonce: aEncryptedMessage[@"nonce"]];
        if (!parsedHeader) {
            continue;
        }
        NACLNonce *innerNonce = [NACLNonce nonceWithData:
                                 [[NSData alloc] initWithBase64EncodedString: parsedHeader[3]
                                                                     options: 0]];
        NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                      options: 0];
        for (NACLSymmetricPrivateKey *messageKey in keyRing.messageKeys) {
            // attempt decryption:
            if ((decryptedMessageBody = [messageBodyData decryptedDataUsingPrivateKey: messageKey
                                                                                nonce: innerNonce
                                                                                error: nil]))
            { // Decryption successful.
                // delete message key from array:
                [keyRing.messageKeys removeObject: messageKey];
                // TODO: could theree be performance gain when deleting by index rather than object?
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
{
    MOBAxolotlChainKey *chainKey = (aChainKey) ? aChainKey : aSession.receiverChainKey;
    NACLSymmetricPrivateKey *headerKey = (aHeaderKey) ? aHeaderKey : aSession.receiverHeaderKey;
    // TODO: check what TS does here with chainkey.index > counter
    if (aFutureMessageNumber - aCurrentMessageNumber > 500)
    { // more than 500 skipped messages (same number TextSecure sets as limit)
        // TODO: error/exception?
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
{
    // attempt to decrypt header with receiverHeaderKey:
    NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                withKey: aSession.receiverHeaderKey
                                               andNonce: aEncryptedMessage[@"nonce"]];
    if (!parsedHeader) {
        return nil;
    }
    
    [self stageSkippedKeysInSession: aSession
               currentMessageNumber: aSession.messagesReceivedCount
                futureMessageNumber: [((NSNumber *) parsedHeader[0]) unsignedIntegerValue]
              usingSpecialHeaderKey: nil
               usingSpecialChainKey: nil]; // passing nil just takes the one from the session.
    
    NACLSymmetricPrivateKey *messageKey = aSession.currentMessageKey;
    
    // attempt to decrypt message body:
    NACLNonce *innerNonce = [NACLNonce nonceWithData:
                                 [[NSData alloc] initWithBase64EncodedString: parsedHeader[3]
                                                                     options: 0]];
    NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                  options: 0];
    NSData *decryptedMessage;
    if (!(decryptedMessage = [messageBodyData decryptedDataUsingPrivateKey: messageKey
                                                               nonce: innerNonce
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
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithCapacity: (512 / 8)];
    crypto_auth_hmacsha256(inputKeyMaterial.mutableBytes,
                           diffieHellman.bytes,
                           [diffieHellman length],
                           aRootKey.bytes);
    NSData *info = [@"MobileEdge Ratchet" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [@"salty" dataUsingEncoding:NSUTF8StringEncoding];
    return [HKDFKit deriveKey: inputKeyMaterial info: info salt: salt outputSize: 3*32];
}

- (NSData *) attemptDecryptionUsingNextHeaderKeyWithSessionState: (MOBAxolotlSession *) aSession
                                                      forMessage: (NSDictionary *) aEncryptedMessage
{
    NSArray *parsedHeader = [self decryptAndParseHeader: aEncryptedMessage[@"head"]
                                                withKey: aSession.receiverNextHeaderKey
                                               andNonce: aEncryptedMessage[@"nonce"]];
    if (!parsedHeader)
    {
        return nil;
    }
    // stage skipped keys for last ratchet:
    [self stageSkippedKeysInSession: aSession
               currentMessageNumber: aSession.messagesReceivedCount
                futureMessageNumber: [((NSNumber *) parsedHeader[1]) unsignedIntegerValue]
              usingSpecialHeaderKey: nil
               usingSpecialChainKey: nil];
    
    NACLSymmetricPrivateKey *purportedHeaderKey = aSession.receiverNextHeaderKey;
    
    // derive new key material from ratchet keys in state and message:
    NSData *derivedKeyMaterial = [self deriveKeyDataWithRootKey: aSession.rootKey
                                                   ourEphemeral: aSession.senderDiffieHellmanKey.privateKey
                                                 theirEphemeral: (NACLAsymmetricPublicKey *) parsedHeader[2]];
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
               usingSpecialChainKey: purportedReceiverChainKey];
    
    // Attempt decrypting message body:
    NACLNonce *innerNonce = [NACLNonce nonceWithData:
                                 [[NSData alloc] initWithBase64EncodedString: parsedHeader[3]
                                                                     options: 0]];
    NSData *messageBodyData = [[NSData alloc] initWithBase64EncodedString: aEncryptedMessage[@"body"]
                                                                  options: 0];
    NSData *decryptedMessageBody = [messageBodyData decryptedDataUsingPrivateKey: aSession.currentMessageKey
                                                                           nonce: innerNonce
                                                                           error: nil];
    if (decryptedMessageBody)
    { // Decryption failed (again).
        return nil;
    }
    
    // set new values/keys in state, erase DH key pair and set ratchet flag:
    [aSession ratchetStateAfterReceivingRootKey: purportedRootKey
                                  nextHeaderKey: purportedReceiverNextHeaderKey
                               diffieHellmanKey: (NACLAsymmetricPublicKey *) parsedHeader[2]];
    
    return decryptedMessageBody;
}

#pragma mark -
#pragma mark Decryption
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                 fromSender: (MOBRemoteIdentity *) aSender
{
    MOBAxolotlSession *session;
    if (!(session = self.sessions[aSender]))
    {
        // TODO: fail! we dont have a session for the given remote!
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
    if ((decryptedMessage = [self attemptDecryptionUsingCurrentHeaderKeyWithSessionState: session //TODO!
                                                                              forMessage: aEncryptedMessage]))
    { // Decryption successful.
        [session advanceStateAfterReceiving];
        return decryptedMessage;
    }
    
    // So far, decryption has _not_ been successful. Advance the state and retry:
    if (session.ratchetFlag)
    { // TODO: set some error
        return nil;
    }
    if (!(decryptedMessage = [self attemptDecryptionUsingNextHeaderKeyWithSessionState: session
                                                                            forMessage: aEncryptedMessage]))
    { // Last decryption attempt has failed. Cannot decrypt.
        return nil;
    }
    // Decryption successful!
    // increase number of received messages, update chain key, commit staged keys:
    [session advanceStateAfterReceiving];
    
    // return decrypted message:
    return decryptedMessage;
}

- (NSData *) decryptData: (NSData *) aEncryptedData
              fromSender: (MOBRemoteIdentity *) aSender
{
#warning stub
    return nil;
}


- (NSData *) decryptBody: (NSString *) aBody
                withHead: (NSString *) aHead
               withNonce: (NSString *) aNonce
{
    NSData *head = 	[[NSData alloc] initWithBase64EncodedString: aHead options: 0];
    NSMutableData *decryptedHeader = [NSMutableData dataWithLength: head.length];
#warning unfinished
    NSMutableData *decrypted = [NSMutableData dataWithLength:0];
    return decrypted;
}

#pragma mark -
#pragma mark Key exchange
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) aSendKeyExchangeBlock
{
    NACLAsymmetricKeyPair *myEphemeralKeyPair = [NACLAsymmetricKeyPair keyPair];
    NSMutableDictionary *keyExchangeMessageOut = [NSMutableDictionary dictionary];
    
    [keyExchangeMessageOut setObject:[self.identity.identityKey.data base64EncodedStringWithOptions: 0] forKey:@"id"];
    [keyExchangeMessageOut setObject:[myEphemeralKeyPair.publicKey.data base64EncodedStringWithOptions:0] forKey:@"eph0"];
    KeyExchangeFinalizeBlock finalizeBlock;
    finalizeBlock = ^(NSData *theirKeyExchangeMessage)
    {
        MOBAxolotlSession *newSession = [[MOBAxolotlSession alloc] initWithMyIdentityKeyPair:self.identity.identityKeyPair
                                                                            theirIdentityKey:aBob.identityKey];
        NSDictionary *keyExchangeMessageIn = [NSJSONSerialization JSONObjectWithData:theirKeyExchangeMessage
                                                                             options:0
                                                                               error:nil]; // TODO: error / conversion might already have been handled!
        [newSession finishKeyAgreementWithKeyExchangeMessage: keyExchangeMessageIn
                                          myEphemeralKeyPair: myEphemeralKeyPair];
        [self addSession:newSession forBob:aBob];
        [self.keychain setObject:self.sessions
                          forKey:self.identity.identityKey];
    };
    if ([NSJSONSerialization isValidJSONObject:keyExchangeMessageOut])
    {
        //aSendKeyExchangeBlock([NSJSONSerialization dataWithJSONObject:keyExchangeMessageOut options:0 error:nil], finalizeBlock);   //TODO: error
        aSendKeyExchangeBlock(keyExchangeMessageOut, finalizeBlock);
    }
    else
    {
        DDLogError(@"Could not generate a valid JSON key exchange message.");
    }
}

#pragma mark -
#pragma mark Session management

- (void) addSession: (MOBAxolotlSession *) aSession
             forBob: (MOBRemoteIdentity *) aBobIdentity
{
    if (!self.sessions) {
        self.sessions = [NSMutableDictionary dictionary];
    }
    [self.sessions setObject:aSession forKey:aBobIdentity];
}
@end
