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
 * Created by Raphael Arias on 8/13/14.
 */

#import <Foundation/Foundation.h>
 //TODO: MOBIdentity inside the session?

@class NACLAsymmetricKeyPair, NACLAsymmetricPublicKey, NACLSymmetricPrivateKey, MOBAxolotlChainKey, MOBAxolotlSkippedKeyRing;

@interface MOBAxolotlSession : NSObject <NSCoding>
#pragma mark -
#pragma mark Identity keys

/**
 * @discussion Our own identity key pair for this session.
 */
@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *myIdentityKeyPair;

/**
 * @discussion The remote's identity key pair for this session.
 */
@property (nonatomic, strong, readonly) NACLAsymmetricPublicKey *theirIdentityKey;

#pragma mark -
/**
 * @discussion The current root key.
 */
@property (nonatomic, strong, readonly) NSData *rootKey;

#pragma mark -
#pragma mark Keys related to sending

/**
 * @discussion The current chain key for sending messages.
 */
@property (nonatomic, strong, readonly) MOBAxolotlChainKey *senderChainKey;

/**
 * @discussion The current header key for sending messages. Used to encrypt the
 * message header.
 */
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *senderHeaderKey;

/**
 * @discussion The next header key for sending messages.
 */
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *senderNextHeaderKey;

/**
 * @discussion The Diffie Hellman ratchet key kair used to ratchet the key material.
 * The public key is attached to outgoing encrypted messages.
 */
@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *senderDiffieHellmanKey;

#pragma mark -
#pragma mark Keys related to receiving

/**
 * @discussion The current chain key for receiving messages.
 */
@property (nonatomic, strong, readonly) MOBAxolotlChainKey *receiverChainKey;

/**
 * @discussion The current header key for receiving messages. Used to decrypt the
 * message header.
 */
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *receiverHeaderKey;

/**
 * @discussion The next header key for receiving messages.
 */
@property (nonatomic, strong, readonly) NACLSymmetricPrivateKey *receiverNextHeaderKey;

/**
 * @discussion The Diffie Hellman public ratchet key of the remote, used to ratchet the key material.
 */
@property (nonatomic, strong, readonly) NACLAsymmetricPublicKey *receiverDiffieHellmanKey;


#pragma mark -
#pragma mark Counters

/**
 * @discussion Count of messages received under this ratchet.
 */
@property (nonatomic, assign, readonly) NSUInteger messagesReceivedCount;

/**
 * @discussion Count of messages sent under this ratchet.
 */
@property (nonatomic, assign, readonly) NSUInteger messagesSentCount;

/**
 * @discussion Count of messages sent under the previous ratchet.
 */
@property (nonatomic, assign, readonly) NSUInteger messagesSentUnderPreviousRatchetCount;

#pragma mark -

@property (nonatomic, assign, readonly) BOOL ratchetFlag;

#pragma mark -
#pragma mark Skipped message handling

/**
 * @discussion A mutable array containing MOBAxolotlSkippedKeyRings for up to 4 different skipped header keys.
 * Those contain a header key and messageKeys arrays for one specific headerKey. 
 * If a new header key is to be added, the oldest keyRing is removed.
 */
@property (nonatomic, strong, readonly) NSMutableArray *skippedHeaderAndMessageKeys;

/**
 * @discussion The staging area where @{ headerKey : @[ message keys ]} are kept until we commit them to
 * the actual skippedKeys storage. 
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *stagingArea;

/**
 * @discussion Reference to a purported chain key. We don't want to overwrite the
 * chain key until we know decryption was successful.
 */
@property (nonatomic, retain) MOBAxolotlChainKey *purportedReceiverChainKey;

/**
 * @discussion Reference to the current message key which should be used to decrypt
 * the message.
 */
@property (nonatomic, retain) NACLSymmetricPrivateKey *currentMessageKey;

#pragma mark -
#pragma mark Init

/**
 * @discussion Initialize a session with identity keys.
 * @param aKeyPair - our identity key pair
 * @param aTheirKey - their identity key
 * @return the initialized session.
 */
- (instancetype) initWithMyIdentityKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
                          theirIdentityKey: (NACLAsymmetricPublicKey *) aTheirKey;

#pragma mark -
#pragma mark Key agreement

/**
 * @discussion Key agreement finalization when we are Alice (the one who
 * initialized the key agreement).
 * @param aKeyExchangeMessageIn - the key exchange message response we received
 * @param aMyEphemeralKeyPair - the ephemeral key pair we used for the key agreement
 */
- (void) finishKeyAgreementWithKeyExchangeMessage: (NSDictionary *) aKeyExchangeMessageIn
                               myEphemeralKeyPair: (NACLAsymmetricKeyPair *) aMyEphemeralKeyPair;

/**
 * @discussion Key agreement finalization when we are Bob (someone else 
 * initialized the key agreement with us).
 * @param aKeyExchangeMessageIn - the key exchange message we received
 * @param aMyEphemeralKeyPair0 - the ephemeral key pair we used for the key agreement
 * @param aMyEphemeralKeyPair1 - the ephemeral key pair we will use as next ratchet key
 */
- (void) finishKeyAgreementWithAliceWithKeyExchangeMessage: (NSDictionary *) aKeyExchangeMessageIn
                                       myEphemeralKeyPair0: (NACLAsymmetricKeyPair *) aMyEphemeralKeyPair0
                                       myEphemeralKeyPair1: (NACLAsymmetricKeyPair *) aMyEphemeralKeyPair1;

#pragma mark -
#pragma mark State advance and ratchet

/**
 * @discussion Ratchet the state before encrypting a new message. This is called
 * when sending a new message and ratchet flag is set.
 */
- (void) ratchetStateBeforeSending;

/**
 * @discussion Advance the state after sending a message. Increments the counter
 * of sent messages.
 */
- (void) advanceStateAfterSending;

/**
 * @discussion Ratchet the state after receiving a message.
 * @param aRootKey - the purported root key to overwrite the current root key
 * @param aNextHeaderKey - the purported next header key
 * @param aDiffieHellmanKey - the purported diffie hellman public ratchet key
 */
- (void) ratchetStateAfterReceivingRootKey: (NSData *) aRootKey
                             nextHeaderKey: (NACLSymmetricPrivateKey *) aNextHeaderKey
                          diffieHellmanKey: (NACLAsymmetricPublicKey *) aDiffieHellmanKey;

/**
 * @discussion Advance the state after receiving a message. Increments the counter
 * of received messages, commits staged keys and might update the chain key.
 */
- (void) advanceStateAfterReceiving;

#pragma mark -
#pragma mark Key staging and committing

/**
 * @discussion Stage message keys for a given header key to be committed later.
 * @param aMessageKeys - the message key array
 * @param aReceiverHeaderKey - the header key associated with the message keys
 */
- (void) stageMessageKeys: (NSMutableArray *) aMessageKeys
             forHeaderKey: (NACLSymmetricPrivateKey *) aReceiverHeaderKey;

/**
 * @discussion Commit previously staged keys
 */
- (void) commitKeysInStagingArea;

#pragma mark -
#pragma mark Cleanup methods

/**
 * @discussion Clear the whole session.
 */
- (void) clearSession;

/**
 * @discussion Clear all the keys from the staging area.
 */
- (void) clearStagingArea;

/**
 * @discussion Clear all the volatile data (purported keys and staged keys).
 */
- (void) clearVolatileData;

@end
