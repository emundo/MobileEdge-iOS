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
 * Created by Raphael Arias on 8/13/14.
 */

#import <Foundation/Foundation.h>

@class NACLAsymmetricKeyPair, NACLAsymmetricPublicKey, NACLSymmetricPrivateKey, MOBAxolotlChainKey;

@interface MOBAxolotlSession : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *myIdentityKeyPair;  //FIXME: type should later be NACLAsymmetricKeyPair
@property (nonatomic, strong, readonly) NACLAsymmetricPublicKey *theirIdentityKey;  //FIXME: type should later be NACLAsymmetricPublicKey
@property (nonatomic, strong, readonly) NSData *rootKey;

@property (nonatomic, strong, readonly) MOBAxolotlChainKey *senderChainKey;
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *senderHeaderKey;
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *senderNextHeaderKey;
@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *senderDiffieHellmanKey; //FIXME: type

@property (nonatomic, strong, readonly) MOBAxolotlChainKey *receiverChainKey;
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *receiverHeaderKey;
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *receiverNextHeaderKey;
@property (nonatomic, strong, readonly) NACLAsymmetricPublicKey *receiverDiffieHellmanKey; //FIXME: type

@property (nonatomic, assign, readonly) NSUInteger messagesReceivedCount;
@property (nonatomic, assign, readonly) NSUInteger messagesSentCount;
@property (nonatomic, assign, readonly) NSUInteger messagesSentUnderPreviousRatchetCount;

@property (nonatomic, assign, readonly) BOOL ratchetFlag;

/**
 * A dictionary containing for each skipped header key, an NSMutableSet with all skipped message keys.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *skippedHeaderAndMessageKeys;

- (instancetype) initWithMyIdentityKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
                          theirIdentityKey: (NACLAsymmetricPublicKey *) aTheirKey;

- (void) addDerivedKeyMaterial: (NSData *) derivedKeyMaterial;

- (void) finishKeyAgreementWithKeyExchangeMessage: (NSDictionary *) keyExchangeMessageIn
                               myEphemeralKeyPair: (NACLAsymmetricKeyPair *) myEphemeralKeyPair;

- (void) advanceStateAfterSending;

- (void) ratchetStateBeforeSending;

@end
