//
//  MOBAxolotl.h
//  
//
//  Created by Raphael Arias on 8/7/14.
//
//

#import <Foundation/Foundation.h>
#import "MOBIdentity.h"

@interface MOBAxolotl : NSObject

- (instancetype) initWithIdentity: (MOBIdentity *) identity;

/**
 * @discussion Encrypt a given message for a given receiver.
 * @param aMessage - the message to encrypt
 * @param aReceiver - the receiver of the message
 * @return the encrypted message or nil if encryption failed
 */
- (NSString *) encryptMessage: (NSString *) aMessage
                  forReceiver: (MOBIdentity *) aReceiver;

/**
 * @discussion Decrypt a given message from a given sender
 * @param aEncryptedMessage - the encrypted message
 * @param aSender - the sender of the message
 * @return the cleartext message if successful or nil if decryption failed
 */
- (NSString *) decryptMessage: (NSString *) aEncryptedMessage
                  fromSender: (MOBIdentity *) aSender;

/**
 * @discussion Perform an Axolotl key agreement with a given peer. 
 *  This will usually be the MobileEdge server or a vendor identity.
 * @param aBob - Bob's identity
 * @param TODO
 */
- (void) performKeyExchangeWithBob: (MOBIdentity *) aBob
    andSendKeyExchangeMessageUsing: (void (^) (NSString * keyExchangeMessage)) sendContinuation;
/*                    withSuccessBlock: (BOOL (^) (void)) successContinuation
                    withFailureBlock: (void (^) (void)) failureContinuation;*/
@end
