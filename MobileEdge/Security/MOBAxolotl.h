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

#import <Foundation/Foundation.h>

@class MOBRemoteIdentity, MOBIdentity;

@interface MOBAxolotl : NSObject

- (instancetype) initWithIdentity: (MOBIdentity *) identity;

/**
 * @discussion Encrypt a given message for a given receiver.
 * @param aMessage - the message to encrypt
 * @param aReceiver - the receiver of the message
 * @return the encrypted message or nil if encryption failed
 */
- (NSString *) encryptMessage: (NSString *) aMessage
                  forReceiver: (MOBRemoteIdentity *) aReceiver;

/**
 * @discussion Decrypt a given message from a given sender
 * @param aEncryptedMessage - the encrypted message
 * @param aSender - the sender of the message
 * @return the cleartext message if successful or nil if decryption failed
 */
- (NSString *) decryptMessage: (NSString *) aEncryptedMessage
                  fromSender: (MOBRemoteIdentity *) aSender;

/**
 * @discussion Perform an Axolotl key agreement with a given peer. 
 *  This will usually be the MobileEdge server or a vendor identity.
 * @param aBob - Bob's identity
 * @param TODO
 */
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (void (^) (NSString * keyExchangeMessage)) sendContinuation;
/*                    withSuccessBlock: (BOOL (^) (void)) successContinuation
                    withFailureBlock: (void (^) (void)) failureContinuation;*/
@end
