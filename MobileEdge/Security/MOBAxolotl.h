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

- (NSString *) encryptMessage: (NSString *) aMessage
                  forReceiver: (MOBIdentity *) aReceiver;
- (NSString *) decryptMessage: (NSString *) aEncryptedMessage
                  fromSender: (MOBIdentity *) aSender;
- (void) performKeyExchangeWithBob: (MOBIdentity *) aParty
    andSendKeyExchangeMessageUsing: (void (^) (NSString * keyExchangeMessage)) sendContinuation;
/*                    withSuccessBlock: (BOOL (^) (void)) successContinuation
                    withFailureBlock: (void (^) (void)) failureContinuation;*/
@end
