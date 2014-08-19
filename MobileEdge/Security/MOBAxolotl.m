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
#import "MOBIdentity.h"
#import "MOBRemoteIdentity.h"
#import "MOBCore.h"
#import "NACLKey+ScalarMult.h"
#import <HKDFKit.h>
#import <SodiumObjc.h>
#import <SodiumObjc/NACLKey.h>

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
    if (self = [super init])
    {
        self.identity = aIdentity;
#warning unfinished
        //TODO: check whether a state for this identity exists in keychain!
    }
    return self;
}


#pragma mark -
#pragma mark Encryption
- (NSString *) encryptMessage: (NSString *) aMessage
                  forReceiver: (MOBRemoteIdentity *) aReceiver
{
#warning stub
    return nil;
}

#pragma mark -
#pragma mark Decryption
- (NSString *) decryptMessage: (NSString *) aEncryptedMessage
                   fromSender: (MOBRemoteIdentity *) aSender
{
#warning stub
    return nil;
}

#pragma mark -
#pragma mark Key exchange
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) sendContinuation
{
    MOBAxolotlSession *newSession = [[MOBAxolotlSession alloc] initWithMyIdentityKeyPair:self.identity.identityKeyPair
                                                                        theirIdentityKey:aBob.identityKey];
    NACLAsymmetricKeyPair *myEphemeralKeyPair = [NACLAsymmetricKeyPair keyPair];
    NSMutableDictionary *keyExchangeMessageOut = [NSMutableDictionary dictionary];
    
    //[keyExchangeMessageOut setObject:[self.identity.identityKey.data description] forKey:@"id"];
    //[keyExchangeMessageOut setObject:[myEphemeralKeyPair.publicKey.data description] forKey:@"eph0"];
    [keyExchangeMessageOut setObject:[self.identity.identityKey.data base64EncodedStringWithOptions: 0] forKey:@"id"];
    [keyExchangeMessageOut setObject:[myEphemeralKeyPair.publicKey.data base64EncodedStringWithOptions:0] forKey:@"eph0"];
    KeyExchangeFinalizeBlock finalizeBlock;
    finalizeBlock = ^(NSData *theirKeyExchangeMessage)
    {
        NSDictionary *keyExchangeMessageIn = [NSJSONSerialization JSONObjectWithData:theirKeyExchangeMessage
                                                                             options:0
                                                                               error:nil]; // TODO: error
        NACLKey *theirId =[NACLKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"id"]
                                                                                    options:0]];
        NACLKey *theirEph0 =[NACLKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph0"]
                                                                                      options:0]];
        NACLKey *theirEph1 =[NACLKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph1"]
                                                                                      options:0]];
        NACLKey *part1 = [self.identity.identityKeyPair.privateKey multWithKey:theirEph0];
        NACLKey *part2 = [myEphemeralKeyPair.privateKey multWithKey: theirId];
        NACLKey *part3 = [myEphemeralKeyPair.privateKey multWithKey: theirEph0];
        NSMutableData *masterSecret = [NSMutableData dataWithCapacity:[NACLKey keyLength] * 3];
        [masterSecret appendData:part1.data];
        [masterSecret appendData:part2.data];
        [masterSecret appendData:part3.data];
        
    };
    if ([NSJSONSerialization isValidJSONObject:keyExchangeMessageOut])
    {
        sendContinuation([NSJSONSerialization dataWithJSONObject:keyExchangeMessageOut options:0 error:nil], finalizeBlock);   //TODO: error
    }
    else
    {
        DDLogError(@"Could not generate a valid JSON key exchange message.");
    }
}

#pragma mark -
#pragma mark Session management

- (void) addSession: (MOBAxolotlSession *) aSession
             forBob: (MOBRemoteIdentity *) aBobIdentity
{
    if (!self.sessions) {
        self.sessions = [NSMutableDictionary dictionary];
    }
    [self.sessions setObject:aSession forKey:aBobIdentity];
}
@end
