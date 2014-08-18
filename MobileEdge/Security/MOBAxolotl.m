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

#pragma mark -
#pragma mark Class Extension

@interface MOBAxolotl ()

@property (nonatomic,strong) MOBIdentity *identity;
@property (nonatomic,strong) NSMutableDictionary *sessions;

- (void) addSession: (MOBAxolotlSession *) aSession
             forBob: (MOBIdentity *) aBobIdentity;

@end

#pragma mark -
#pragma mark Implementation

@implementation MOBAxolotl

- (instancetype) initWithIdentity: (MOBIdentity *) aIdentity
{
    self.identity = aIdentity;
    return self;
}


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
- (void) performKeyExchangeWithBob: (MOBIdentity *) aBob
    andSendKeyExchangeMessageUsing: (void (^) (NSString * keyExchangeMessage)) sendContinuation
{
    
}

#pragma mark -
#pragma mark Session management

- (void) addSession: (MOBAxolotlSession *) aSession
             forBob: (MOBIdentity *) aBobIdentity
{
    if (!self.sessions) {
        self.sessions = [NSMutableDictionary dictionary];
    }
    [self.sessions setObject:aSession forKey:aBobIdentity];
}
@end
