//
//  MOBAxolotl.m
//  
//
//  Created by Raphael Arias on 8/7/14.
//
//

#import "MOBAxolotl.h"

@implementation MOBAxolotl
#pragma mark -
#pragma mark Encryption
- (NSString *) encryptMessage: (NSString *) aMessage
                  forReceiver: (MOBIdentity *) aReceiver
{
#pragma warning stub
    return nil;
}

#pragma mark -
#pragma mark Decryption
- (NSString *) decryptMessage: (NSString *) aEncryptedMessage
                   fromSender: (MOBIdentity *) aSender
{
#pragma warning stub
    return nil;
}

#pragma mark -
#pragma mark Key exchange
- (void) performKeyExchangeWithBob: (MOBIdentity *) aParty
    andSendKeyExchangeMessageUsing: (void (^) (NSString * keyExchangeMessage)) sendContinuation
{
    
}
@end
