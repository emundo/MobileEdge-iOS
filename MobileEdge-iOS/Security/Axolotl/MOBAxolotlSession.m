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
#import "MOBCore.h"
#import "MOBAxolotlSession.h"
#import "MOBAxolotlChainKey.h"
#import "MOBAxolotlSkippedKeyRing.h"
#import "NACLKey+ScalarMult.h"
#import "NACLKey+Base64.h"
#import "HKDFKit+Strings.h"
#import <HKDFKit.h>
#import <SodiumObjc.h>
#import <sodium/crypto_hash.h>
#import <sodium.h>

#pragma mark Defines for NSCoding keys

#define kMOBAxolotlSessionIdentityKeyPairKey @"identityKeyPair"
#define kMOBAxolotlSessionTheirIdentityKeyKey @"theirIdentityKey"

#define kMOBAxolotlSessionRootKeyKey @"rootKey"

#define kMOBAxolotlSessionSenderChainKeyKey @"senderChainKey"
#define kMOBAxolotlSessionSenderHeaderKeyKey @"senderHeaderKey"
#define kMOBAxolotlSessionSenderNextHeaderKeyKey @"senderNextHeaderKey"
#define kMOBAxolotlSessionSenderDiffieHellmanKeyKey @"senderDiffieHellmanKey"

#define kMOBAxolotlSessionReceiverChainKeyKey @"receiverChainKey"
#define kMOBAxolotlSessionReceiverHeaderKeyKey @"receiverHeaderKey"
#define kMOBAxolotlSessionReceiverNextHeaderKeyKey @"receiverNextHeaderKey"
#define kMOBAxolotlSessionReceiverDiffieHellmanKeyKey @"receiverDiffieHellmanKey"

#define kMOBAxolotlSessionMessagesReceivedCountKey @"messagesReceivedCount"
#define kMOBAxolotlSessionMessagesSentCountKey @"messagesSentCount"
#define kMOBAxolotlSessionMessagesSentUnderPreviousRatchetCountKey @"messagesSentUnderPreviousRatchetCount"

#define kMOBAxolotlSessionRatchetFlagKey @"ratchetFlag"
#define kMOBAxolotlSessionSkippedHeaderAndMessageKeysKey @"skippedHeaderAndMessageKeys"

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
    }
    return self;
}

- (void) addDerivedKeyMaterialAsAlice: (NSData *) aDerivedKeyMaterial
{
    _rootKey = [aDerivedKeyMaterial subdataWithRange: NSMakeRange(0, 32)];
    _receiverHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                          [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*1, 32)]];
    _senderNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                            [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*2, 32)]];
    _receiverNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                              [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*3, 32)]];
    _receiverChainKey = [[MOBAxolotlChainKey alloc] initWithKeyData:
                         [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*4, 32)]];
}

- (void) addDerivedKeyMaterialAsBob: (NSData *) aDerivedKeyMaterial
{
    _rootKey = [aDerivedKeyMaterial subdataWithRange: NSMakeRange(0, 32)];
    _senderHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                          [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*1, 32)]];
    _receiverNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                            [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*2, 32)]];
    _senderNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                              [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*3, 32)]];
    _senderChainKey = [[MOBAxolotlChainKey alloc] initWithKeyData:
                         [aDerivedKeyMaterial subdataWithRange: NSMakeRange(32*4, 32)]];
}

- (void) finishKeyAgreementWithKeyExchangeMessage: (NSDictionary *) keyExchangeMessageIn
                               myEphemeralKeyPair: (NACLAsymmetricKeyPair *) myEphemeralKeyPair
{
    NACLAsymmetricPublicKey *theirId =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"id"]
                                             options: 0]];
    NACLAsymmetricPublicKey *theirEph0 =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph0"]
                                             options: 0]];
    NACLAsymmetricPublicKey *theirEph1 =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: keyExchangeMessageIn[@"eph1"]
                                             options: 0]];
    NACLKey *part1 = [self.myIdentityKeyPair.privateKey multWithKey: theirEph0];
    NACLKey *part2 = [myEphemeralKeyPair.privateKey multWithKey: theirId];
    NACLKey *part3 = [myEphemeralKeyPair.privateKey multWithKey: theirEph0];
    
    NSMutableData *masterSecret = [NSMutableData dataWithCapacity: 32 * 3];
    [masterSecret appendData: part1.data];
    [masterSecret appendData: part2.data];
    [masterSecret appendData: part3.data];
    [self addDerivedKeyMaterialAsAlice: [self deriveKeyDataFromMasterSecret: masterSecret]];
    
    _receiverDiffieHellmanKey = theirEph1;
    _ratchetFlag = YES;
    DDLogVerbose(@"Finished key agreement. Session: %@", self);
}

- (NSData *) deriveKeyDataFromMasterSecret: (NSMutableData *) aMasterSecret
{
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithLength: (512 / 8)];
    crypto_hash(inputKeyMaterial.mutableBytes, aMasterSecret.bytes, 32 * 3);
    
    return [HKDFKit deriveKey: inputKeyMaterial
                   infoString: @"MobileEdge"
                   saltString: @"salty"
                   outputSize: 5*32];
}

- (void) finishKeyAgreementWithAliceWithKeyExchangeMessage: (NSDictionary *) aKeyExchangeMessageIn
                                       myEphemeralKeyPair0: (NACLAsymmetricKeyPair *) aMyEphemeralKeyPair0
                                       myEphemeralKeyPair1: (NACLAsymmetricKeyPair *) aMyEphemeralKeyPair1
{
    NACLAsymmetricPublicKey *theirId =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: aKeyExchangeMessageIn[@"id"]
                                             options: 0]];
    NACLAsymmetricPublicKey *theirEph0 =
        [[NACLAsymmetricPublicKey alloc] initWithData:
         [[NSData alloc] initWithBase64EncodedString: aKeyExchangeMessageIn[@"eph0"]
                                             options: 0]];
    
    NACLKey *part1 = [aMyEphemeralKeyPair0.privateKey multWithKey: theirId];
    NACLKey *part2 = [self.myIdentityKeyPair.privateKey multWithKey:theirEph0];
    NACLKey *part3 = [aMyEphemeralKeyPair0.privateKey multWithKey: theirEph0];
    
    NSMutableData *masterSecret = [NSMutableData dataWithCapacity: 32 * 3];
    [masterSecret appendData: part1.data];
    [masterSecret appendData: part2.data];
    [masterSecret appendData: part3.data];
    [self addDerivedKeyMaterialAsBob: [self deriveKeyDataFromMasterSecret: masterSecret]];
    
    _senderDiffieHellmanKey = aMyEphemeralKeyPair1;
    _ratchetFlag = NO;
    DDLogVerbose(@"Finished key agreement. Session: %@", self);
}

- (void) advanceStateAfterSending
{
    _messagesSentCount += 1;
    // deriving a new chain key can be omitted, as deriving the new message key took care of that
}

- (void) advanceStateAfterReceiving
{
    _messagesReceivedCount += 1;
    if (self.purportedReceiverChainKey)
    {
        _receiverChainKey = self.purportedReceiverChainKey;
    }
    [self commitKeysInStagingArea];
}

- (void) ratchetStateAfterReceivingRootKey: (NSData *) aRootKey
                             nextHeaderKey: (NACLSymmetricPrivateKey *) aNextHeaderKey
                          diffieHellmanKey: (NACLAsymmetricPublicKey *) aDiffieHellmanKey
{
    _rootKey = aRootKey;
    _receiverHeaderKey = self.receiverNextHeaderKey;
    _receiverNextHeaderKey = aNextHeaderKey;
    _receiverDiffieHellmanKey = aDiffieHellmanKey;
    _senderDiffieHellmanKey = nil; // delete?
    _ratchetFlag = YES;
}

- (void) ratchetStateBeforeSending
{
    _senderDiffieHellmanKey = [NACLAsymmetricKeyPair keyPair];
    _senderHeaderKey = _senderNextHeaderKey;
    NSData *diffieHellman = [self.senderDiffieHellmanKey.privateKey multWithKey: self.receiverDiffieHellmanKey].data;
    NSMutableData *inputKeyMaterial = [NSMutableData dataWithLength: (256 / 8)];
    crypto_auth_hmacsha256(inputKeyMaterial.mutableBytes,
                           diffieHellman.bytes,
                           [diffieHellman length],
                           self.rootKey.bytes);
    NSData *derivedKeyMaterial = [HKDFKit deriveKey: inputKeyMaterial
                                         infoString: @"MobileEdge Ratchet"
                                         saltString: @"salty"
                                         outputSize: 3*32];
    
    _rootKey = [derivedKeyMaterial subdataWithRange: NSMakeRange(0, 32)];
    _senderNextHeaderKey = [NACLSymmetricPrivateKey keyWithData:
                            [derivedKeyMaterial subdataWithRange: NSMakeRange(1*32, 32)]];
    _senderChainKey = [[MOBAxolotlChainKey alloc] initWithKeyData:
                       [derivedKeyMaterial subdataWithRange: NSMakeRange(2*32, 32)]];
    
    _messagesSentUnderPreviousRatchetCount = _messagesSentCount;
    _messagesSentCount = 0;
    _ratchetFlag = NO;
}

- (void) stageMessageKeys: (NSMutableArray *) aMessageKeys
             forHeaderKey: (NACLSymmetricPrivateKey *) aReceiverHeaderKey
{
    if (0 == [aMessageKeys count])
    { // Nothing to be staged
        return;
    }
    if (!self.stagingArea)
    { // lazily instantiate:
        _stagingArea = [NSMutableDictionary dictionaryWithCapacity: 1];
    }
    [self.stagingArea setObject: aMessageKeys
                         forKey: [aReceiverHeaderKey base64]];
}

- (void) commitKeysInStagingArea
{
    if (!self.stagingArea)
    {
        return;
    }
    if (!self.skippedHeaderAndMessageKeys)
    { // lazily instantiate:
        _skippedHeaderAndMessageKeys = [NSMutableArray arrayWithCapacity: 4];
    }
    // find out which header key is already included:
    for (MOBAxolotlSkippedKeyRing *keyRing in self.skippedHeaderAndMessageKeys)
    { // check if we have message keys for existing skippedKeyStores:
        if (!self.stagingArea[[keyRing.headerKey base64]])
        {
            continue;
        }
        // if the header key is already present, append the message keys:
        [keyRing.messageKeys addObjectsFromArray: self.stagingArea[[keyRing.headerKey base64]]];
        [self.stagingArea removeObjectForKey: [keyRing.headerKey base64]];
    }
    /* if the staging area is not empty by now, we either
     * - need to get rid of the oldest key ring and
     *      add a new one or
     * - have not added any skipped keys before. 
     *
     * We cannot be sure that only one header key + message keys are newly
     * introduced to the skipped keys. It is possible that no keys were 
     * skipped for the last two ratchets; and that skipped keys for both the 
     * last and the new current header key have to be commited.
     * So, to cover this case, we iterate over all the entries that are left:
     */
    void (^iterator) (id key, id obj, BOOL *stop);
    iterator = ^(id aHeaderKey, id aMessageKeys, BOOL *stop)
    {
        NSData *keyData = [[NSData alloc] initWithBase64EncodedString: aHeaderKey options: 0];
        NACLSymmetricPrivateKey *headerKey = [[NACLSymmetricPrivateKey alloc] initWithData: keyData];
        NSMutableArray *messageKeys = aMessageKeys;
        MOBAxolotlSkippedKeyRing *newKeyRing =
            [[MOBAxolotlSkippedKeyRing alloc] initWithMessageKeys: messageKeys
                                                     forHeaderKey: headerKey];
        if (self.skippedHeaderAndMessageKeys.count == 4)
        { // only remove entries at the beginning if 4 entries are full:
            [self.skippedHeaderAndMessageKeys removeObjectAtIndex: 0];
        }
        [self.skippedHeaderAndMessageKeys addObject: newKeyRing];
    };
    [self.stagingArea enumerateKeysAndObjectsUsingBlock: iterator];
    
}

- (void) clearStagingArea
{
    [self.stagingArea removeAllObjects];
}

- (void) clearVolatileData
{
    [self clearStagingArea];
    self.purportedReceiverChainKey = nil;
    self.currentMessageKey = nil;
}

- (void) clearSession
{
    // TODO: clear from KeyChain!
    _myIdentityKeyPair                     = nil;
    _theirIdentityKey                      = nil;
    _rootKey                               = nil;
    _senderChainKey                        = nil;
    _senderHeaderKey                       = nil;
    _senderNextHeaderKey                   = nil;
    _senderDiffieHellmanKey                = nil;
    _receiverChainKey                      = nil;
    _receiverHeaderKey                     = nil;
    _receiverNextHeaderKey                 = nil;
    _receiverDiffieHellmanKey              = nil;
    _messagesReceivedCount                 = 0;
    _messagesSentCount                     = 0;
    _messagesSentUnderPreviousRatchetCount = 0;
    _skippedHeaderAndMessageKeys           = nil;
    _ratchetFlag                           = nil;
    
    [self clearVolatileData];
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"[AxolotlSession]\nidKeyPair:%@\ntheirIdKey:%@\nrootKey:%@",
                        self.myIdentityKeyPair, self.theirIdentityKey, self.rootKey];
}

#pragma mark NSCoding
- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: _myIdentityKeyPair  forKey: kMOBAxolotlSessionIdentityKeyPairKey];
    [encoder encodeObject: _theirIdentityKey  forKey: kMOBAxolotlSessionTheirIdentityKeyKey];
    
    [encoder encodeObject: _rootKey                               forKey: kMOBAxolotlSessionRootKeyKey];
    [encoder encodeObject: _senderChainKey                        forKey: kMOBAxolotlSessionSenderChainKeyKey];
    [encoder encodeObject: _senderHeaderKey                  forKey: kMOBAxolotlSessionSenderHeaderKeyKey];
    [encoder encodeObject: _senderNextHeaderKey                forKey: kMOBAxolotlSessionSenderNextHeaderKeyKey];
    [encoder encodeObject: _senderDiffieHellmanKey              forKey: kMOBAxolotlSessionSenderDiffieHellmanKeyKey];
    [encoder encodeObject: _receiverChainKey                      forKey: kMOBAxolotlSessionReceiverChainKeyKey];
    [encoder encodeObject: _receiverHeaderKey                    forKey: kMOBAxolotlSessionReceiverHeaderKeyKey];
    [encoder encodeObject: _receiverNextHeaderKey                forKey: kMOBAxolotlSessionReceiverNextHeaderKeyKey];
    [encoder encodeObject: _receiverDiffieHellmanKey             forKey: kMOBAxolotlSessionReceiverDiffieHellmanKeyKey];
    [encoder encodeInteger: _messagesReceivedCount                 forKey: kMOBAxolotlSessionMessagesReceivedCountKey];
    [encoder encodeInteger: _messagesSentCount                     forKey: kMOBAxolotlSessionMessagesSentCountKey];
    [encoder encodeInteger: _messagesSentUnderPreviousRatchetCount forKey: kMOBAxolotlSessionMessagesSentUnderPreviousRatchetCountKey];
    [encoder encodeBool: _ratchetFlag                           forKey: kMOBAxolotlSessionRatchetFlagKey];
    [encoder encodeObject: _skippedHeaderAndMessageKeys           forKey: kMOBAxolotlSessionSkippedHeaderAndMessageKeysKey];
    
    // TODO: also encode temporary fields?
}

/*
- (NACLKey *) restoreKeyFromBase64: (NSString *) base64String // TODO: dow e have to differentiate between pub/priv keys?
{
    return [NACLKey keyWithData: [[NSData alloc] initWithBase64EncodedString: base64String
                                                                     options: 0 ]];
}

- (NACLAsymmetricKeyPair *) restoreKeyPairFromBase64Dictionary: (NSDictionary *) base64Dictionary
{
    NACLAsymmetricKeyPair *keyPair = [[NACLAsymmetricKeyPair alloc] init];
    keyPair.privateKey = [[NSData alloc] initWithBase64EncodedString: base64Dictionary[@"privateKey"]
                                                                  options: 0];
} */

- (id)initWithCoder: (NSCoder *) coder
{
    NACLAsymmetricKeyPair *identityKeyPair =
        [coder decodeObjectOfClass: [NACLAsymmetricKeyPair class]
                            forKey: kMOBAxolotlSessionIdentityKeyPairKey];
    NACLAsymmetricPublicKey *theirIdentityKey =
        [coder decodeObjectOfClass: [NACLAsymmetricPublicKey class]
                            forKey: kMOBAxolotlSessionTheirIdentityKeyKey];
    if (self = [self initWithMyIdentityKeyPair: identityKeyPair theirIdentityKey: theirIdentityKey])
    {
        _rootKey                                = [coder decodeObjectForKey: kMOBAxolotlSessionRootKeyKey];
        _senderChainKey                         = [coder decodeObjectOfClass: [MOBAxolotlChainKey class] forKey: kMOBAxolotlSessionSenderChainKeyKey];
        _senderHeaderKey                        = [coder decodeObjectForKey: kMOBAxolotlSessionSenderHeaderKeyKey];
        _senderNextHeaderKey                    = [coder decodeObjectForKey: kMOBAxolotlSessionSenderNextHeaderKeyKey];
        _senderDiffieHellmanKey                 = [coder decodeObjectForKey: kMOBAxolotlSessionSenderDiffieHellmanKeyKey];
        _receiverChainKey                       = [coder decodeObjectOfClass: [MOBAxolotlChainKey class] forKey: kMOBAxolotlSessionReceiverChainKeyKey];
        _receiverHeaderKey                      = [coder decodeObjectForKey: kMOBAxolotlSessionReceiverHeaderKeyKey];
        _receiverNextHeaderKey                  = [coder decodeObjectForKey: kMOBAxolotlSessionReceiverNextHeaderKeyKey];
        _receiverDiffieHellmanKey               = [coder decodeObjectForKey: kMOBAxolotlSessionReceiverDiffieHellmanKeyKey];
        _messagesReceivedCount                  = [coder decodeIntegerForKey: kMOBAxolotlSessionMessagesReceivedCountKey];
        _messagesSentCount                      = [coder decodeIntegerForKey: kMOBAxolotlSessionMessagesSentCountKey];
        _messagesSentUnderPreviousRatchetCount  = [coder decodeIntegerForKey: kMOBAxolotlSessionMessagesSentUnderPreviousRatchetCountKey];
        _ratchetFlag                            = [coder decodeBoolForKey: kMOBAxolotlSessionRatchetFlagKey];
        _skippedHeaderAndMessageKeys            = [coder decodeObjectForKey: kMOBAxolotlSessionSkippedHeaderAndMessageKeysKey];
        
        // TODO: also decode temporary fields?
    }
    return self;
}

@end
