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

@class NACLAsymmetricKeyPair, NACLAsymmetricPublicKey, NACLSymmetricPrivateKey, MOBAxolotlChainKey, MOBAxolotlSkippedKeyRing;

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
 * A mutable array containing MOBAxolotlSkippedKeyStores for up to 4 different skipped header keys.
 * Those contain a header key and messageKeys arrays for one specific headerKey. 
 * If a new header key is to be added, the oldest keyStore is removed.
 */
@property (nonatomic, strong, readonly) NSMutableArray *skippedHeaderAndMessageKeys;

/**
 * The staging area where @{ headerKey : @[ message keys ]} are kept until we commit them to
 * the actual skippedKeys storage. 
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *stagingArea;
@property (nonatomic, retain) MOBAxolotlChainKey *purportedReceiverChainKey;
@property (nonatomic, retain) NACLSymmetricPrivateKey *currentMessageKey;



- (instancetype) initWithMyIdentityKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
                          theirIdentityKey: (NACLAsymmetricPublicKey *) aTheirKey;

- (void) addDerivedKeyMaterial: (NSData *) derivedKeyMaterial;

- (void) finishKeyAgreementWithKeyExchangeMessage: (NSDictionary *) keyExchangeMessageIn
                               myEphemeralKeyPair: (NACLAsymmetricKeyPair *) myEphemeralKeyPair;

- (void) advanceStateAfterSending;

- (void) ratchetStateBeforeSending;

- (void) stageMessageKeys: (NSMutableArray *) aMessageKeys
             forHeaderKey: (NACLSymmetricPrivateKey *) aReceiverHeaderKey;

- (void) commitKeysInStagingArea;

- (void) clearSession;

- (void) clearStagingArea;

- (void) clearVolatileData;

@end
