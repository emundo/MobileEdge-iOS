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
//typedef void (^KeyExchangeSendBlock) (NSData * keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock);
typedef void (^KeyExchangeSendBlock) (NSDictionary * keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock);


@protocol MOBProtocol <NSObject>

- (instancetype) initWithIdentity: (MOBIdentity *) identity;

/**
 * @discussion Encrypt a given message for a given recipient.
 * @param aMessage - the message to encrypt
 * @param aRecipient - the receiver of the message
 * @return the encrypted message or nil if encryption failed
 */
- (NSString *) encryptMessage: (NSString *) aMessage
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
- (NSString *) decryptMessage: (NSDictionary *) aEncryptedMessage
                   fromSender: (MOBRemoteIdentity *) aSender;

/**
 * @discussion Decrypt given data from a given sender
 * @param aEncryptedData - the encrypted data
 * @param aSender - the sender of the data
 * @return the cleartext data if successful or nil if decryption failed
 */
- (NSData *) decryptData: (NSData *) aEncryptedData
              fromSender: (MOBRemoteIdentity *) aSender;

- (NSData *) decryptBody: (NSString *) aBody
                withHead: (NSString *) aHead
               withNonce: (NSString *) aNonce;

/**
 * @discussion Perform an Axolotl key agreement with a given peer.
 *  This will usually be the MobileEdge server or a vendor identity.
 * @param aBob - Bob's identity
 * @param TODO
 */
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) aSendKeyExchangeBlock;
//andSendKeyExchangeMessageUsing: (void (^) (NSData * keyExchangeMessage)) sendContinuation;
/*                    withSuccessBlock: (BOOL (^) (void)) successContinuation
 withFailureBlock: (void (^) (void)) failureContinuation;*/
@end
