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
              usingSpecialChainKey: (MOBAxolotlChainKey *) aChainKey
{
    MOBAxolotlChainKey *chainKey = (aChainKey) ? aChainKey : aSession.receiverChainKey;
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
    [aSession stageMessageKeys: messageKeys forHeaderKey: aSession.receiverHeaderKey];
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
    
    // TODO: derive message keys according to messagesSentCounter:
    NSUInteger currentMessageCount = aSession.messagesReceivedCount;
    NSUInteger messageNumber = [((NSNumber *) parsedHeader[0]) unsignedIntegerValue];
    NSMutableArray *messageKeys = [NSMutableArray arrayWithCapacity: messageNumber - currentMessageCount + 1];
    NACLSymmetricPrivateKey *messageKey;
    for (NSUInteger i = currentMessageCount; i < messageNumber; i++) {
        messageKey = [aSession.receiverChainKey nextMessageKey];
        [messageKeys addObject: messageKey];
    }
    [aSession stageMessageKeys: messageKeys forHeaderKey: aSession.receiverHeaderKey];
    messageKey = [aSession.receiverChainKey nextMessageKey];
    // TODO: attempt to decrypt message body
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
    
    // [aSession.skippedHeaderAndMessageKeys setObject: aSession.stagingArea forKey: aSession.receiverHeaderKey];
    // If we get here, it means we successfully decrypted the message and we can hand it back:
    return decryptedMessage;
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
    // TODO: stage a lot of skipped keys:
    // TODO: derive new key material from ratchet keys in state and message:
    // TODO: potentially stage more keys:
    // TODO: set new values/keys in state:
    // TODO: erase DH key pair:
    // TODO: set ratchetFlag
    return nil;
}

#pragma mark -
#pragma mark Decryption
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                 fromSender: (MOBRemoteIdentity *) aSender
{
#warning stub
    MOBAxolotlSession *session;
    if (!(session = self.sessions[aSender]))
    {
        // TODO: fail! we dont have a session for the given remote!
    }
    
    NSData *decryptedMessage;
    
    // TODO: try decrypting with skipped header and message keys:
    if ((decryptedMessage = [self attemptDecryptionWithSkippedKeys: session.skippedHeaderAndMessageKeys
                                                        forMessage: aEncryptedMessage]))
    { // Decryption successful.
        return decryptedMessage;
    }
    // TODO: try decrypting with current header key:
    if ((decryptedMessage = [self attemptDecryptionUsingCurrentHeaderKeyWithSessionState: session //TODO!
                                                                              forMessage: aEncryptedMessage]))
    { // Decryption successful.
        return decryptedMessage;
    }
    // So far, decryption has not been successful. Advance the state and retry:
    if (session.ratchetFlag)
    { // TODO: set some error
        return nil;
    }
    //if (!(decryptedHeader)) {
    //}
    // TODO: derive keys (advancing state) until we find a matching one:
    // commit staged keys if not happened already:
    [session commitKeysInStagingArea];
    // TODO: increase number of received messages, update chain key
    // TODO: return decrypted message, if any:
    
    return nil;
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
