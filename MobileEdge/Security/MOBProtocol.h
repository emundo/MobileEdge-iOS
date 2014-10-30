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
 * Created by Raphael Arias on 15/10/14.
 */

#import <Foundation/Foundation.h>
@class MOBRemoteIdentity, MOBIdentity;

typedef void (^KeyExchangeFinalizeBlock) (NSData *keyExchangeMessageIn);
typedef void (^KeyExchangeSendBlock) (NSDictionary *keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock);
typedef void (^KeyExchangeSendBlockBob) (NSDictionary *keyExchangeMessage);


@protocol MOBProtocol <NSObject>

/**
 * @discussion Initialize a protocol session using a given Identity.
 * @param identity - the identity to use fot the new session
 * @return the initialized protocol instance.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) identity;

/**
 * @discussion Encrypt a given message for a given recipient.
 * @param aMessage - the message to encrypt
 * @param aRecipient - the receiver of the message
 * @return the encrypted message or nil if encryption failed
 */
- (NSDictionary *) encryptMessage: (NSString *) aMessage
                 forRecipient: (MOBRemoteIdentity *) aRecipient;

/**
 * @discussion Encrypt given data for a given recipient.
 * @param aData - the data to encrypt
 * @param aRecipient - the recipient
 * @return the encrypted data as a dictionary to be used in a JSON object.
 */
- (NSDictionary *) encryptData: (NSData *) aData
                  forRecipient: (MOBRemoteIdentity *) aRecipient;

/**
 * @discussion Decrypt a given message from a given sender
 * @param aEncryptedMessage - the encrypted message
 * @param aSender - the sender of the message
 * @return the cleartext message if successful or nil if decryption failed
 */
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                 fromSender: (MOBRemoteIdentity *) aSender;

/**
 * @discussion Decrypt given data from a given sender
 * @param aEncryptedData - the encrypted data
 * @param aSender - the sender of the data
 * @return the cleartext string if successful or nil if decryption failed
 */
- (NSString *) decryptedStringFromMessage: (NSDictionary *) aEncryptedMessage
                               fromSender: (MOBRemoteIdentity *) aSender;

/**
 * @discussion Decrypts a given message, if a session can be found for the sender.
 * Note: The message object MUST contain the sender's identity encrypted with
 * our public key, else the decryption will fail. This function is provided as
 * a convenience function to client applications that don't want to manage
 * identities themselves.
 * @param aEncryptedMessage - the encrypted message including (!) encrypted sender
 *  information.
 * @return the decrypted data
 */
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage;


/**
 * @discussion Perform an Axolotl key agreement with a given peer.
 *  This will usually be the MobileEdge server or a vendor identity.
 * @param aBob - Bob's identity
 * @param aSendKeyExchangeBlock - the block we should use to send a key exchange
 *  message.
 */
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) aSendKeyExchangeBlock;

/**
 * @discussion Perform a key exchange with someone who initiated a key exchange
 * with us.
 * @param aAlice - Alice's identity.
 * @param aTheirKeyExchangeMessage - the key exchange message we received.
 * @param aSendKeyExchangeBlock - the block we should use to send our key exchange
 *  message.
 */
- (void) performKeyExchangeWithAlice: (MOBRemoteIdentity *) aAlice
             usingKeyExchangeMessage: (NSData *) aTheirKeyExchangeMessage
      andSendKeyExchangeMessageUsing: (KeyExchangeSendBlockBob) aSendKeyExchangeBlock;
@end
