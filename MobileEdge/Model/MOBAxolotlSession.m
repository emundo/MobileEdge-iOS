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
#import "MOBCore.h"
#import "MOBAxolotlSession.h"
#import "NACLKey+ScalarMult.h"
#import <HKDFKit.h>
#import <SodiumObjc.h>
#import <sodium/crypto_hash.h>
#import <sodium.h>

@implementation MOBAxolotlSession

- (instancetype) initWithMyIdentityKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
                          theirIdentityKey: (NACLAsymmetricPublicKey *) aTheirKey
{
    if (self = [super init])
    {
        _myIdentityKeyPair = aKeyPair;
        _theirIdentityKey = aTheirKey;
        _messagesSentCount = 0;
        _messagesReceivedCount = 0;
        _messagesSentUnderPreviousRatchetCount = 0;
        _ratchetFlag = YES;
    }
    return self;
}

- (void) addDerivedKeyMaterial: (NSData *) derivedKeyMaterial
{
    _rootKey = [derivedKeyMaterial subdataWithRange:NSMakeRange(0, 32)];
    _receiverHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                          [derivedKeyMaterial subdataWithRange:NSMakeRange(32*1, 32)]];
    _senderNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                            [derivedKeyMaterial subdataWithRange:NSMakeRange(32*2, 32)]];
    _receiverNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                              [derivedKeyMaterial subdataWithRange:NSMakeRange(32*3, 32)]];
    _receiverChainKey = [derivedKeyMaterial subdataWithRange:NSMakeRange(32*4, 32)];
}

- (void) finishKeyAgreementWithKeyExchangeMessage: (NSDictionary *) keyExchangeMessageIn
                               myEphemeralKeyPair: (NACLAsymmetricKeyPair *) myEphemeralKeyPair
{
    NACLAsymmetricPublicKey *theirId =[NACLAsymmetricPublicKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"id"]
                                                                                options:0]];
    NACLAsymmetricPublicKey *theirEph0 =[NACLAsymmetricPublicKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph0"]
                                                                                  options:0]];
    NACLAsymmetricPublicKey *theirEph1 =[NACLAsymmetricPublicKey keyWithData: [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph1"]
                                                                                  options:0]];
    NACLKey *part1 = [self.myIdentityKeyPair.privateKey multWithKey:theirEph0];
    NACLKey *part2 = [myEphemeralKeyPair.privateKey multWithKey: theirId];
    NACLKey *part3 = [myEphemeralKeyPair.privateKey multWithKey: theirEph0];
    
    NSMutableData *masterSecret = [NSMutableData dataWithCapacity:[NACLKey keyLength] * 3];
    [masterSecret appendData:part1.data];
    [masterSecret appendData:part2.data];
    [masterSecret appendData:part3.data];
    
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithCapacity: (512 / 8)];
    crypto_hash(inputKeyMaterial.mutableBytes, masterSecret.bytes, [NACLKey keyLength] * 3);
    
    NSData *info = [@"MobileEdge" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [@"salty" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *derivedKeyMaterial = [HKDFKit deriveKey: masterSecret info: info salt: salt outputSize: 5*32];
    [self addDerivedKeyMaterial: derivedKeyMaterial];
    _receiverDiffieHellmanKey = theirEph1;
    DDLogVerbose(@"Finished key agreement. Session: %@", self);
}

- (void) advanceStateAfterSending
{
    _messagesSentCount += 1;
    NSMutableData *newChainKey = [NSMutableData dataWithLength: self.senderChainKey.length];
    crypto_auth_hmacsha256(newChainKey.mutableBytes, (unsigned char *) "1", 1, self.senderChainKey.bytes);
    _senderChainKey = newChainKey;
}
- (void) ratchetStateBeforeSending
{
    _senderDiffieHellmanKey = [NACLAsymmetricKeyPair keyPair];
    _senderHeaderKey = _senderNextHeaderKey;
    NSData *diffieHellman = [self.senderDiffieHellmanKey.privateKey multWithKey: self.receiverDiffieHellmanKey].data;
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithCapacity: (512 / 8)];
    crypto_auth_hmacsha256(inputKeyMaterial.mutableBytes,
                           diffieHellman.bytes,
                           [diffieHellman length],
                           self.rootKey.bytes);
    NSData *info = [@"MobileEdge Ratchet" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [@"salty" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *derivedKeyMaterial = [HKDFKit deriveKey: inputKeyMaterial info: info salt: salt outputSize: 3*32];
    _rootKey = [derivedKeyMaterial subdataWithRange: NSMakeRange(0, 32)];
    _senderNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                            [derivedKeyMaterial subdataWithRange:NSMakeRange(1*32, 32)]];
    _senderChainKey = [derivedKeyMaterial subdataWithRange:NSMakeRange(2*32, 32)];
    
    _messagesSentUnderPreviousRatchetCount = _messagesSentCount;
    _messagesSentCount = 0;
    _ratchetFlag = NO;
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"[AxolotlSession]\nidKeyPair:%@\ntheirIdKey:%@\nrootKey:%@",
                        self.myIdentityKeyPair, self.theirIdentityKey, self.rootKey];
}

@end
