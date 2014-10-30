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
 * Created by Raphael Arias on 16/10/14.
 */

#import "MOBAxolotlChainKey.h"
#import <SodiumObjc.h>
#import <sodium.h>

@implementation MOBAxolotlChainKey

- (instancetype) initWithKeyData: (NSData *) aInputData
{
    if (self = [super init])
    {
        _data = aInputData;
    }
    return self;
}

- (void) nextChainKey
{
    NSMutableData *newChainKey = [NSMutableData dataWithLength: self.data.length];
    crypto_auth_hmacsha256(newChainKey.mutableBytes, (unsigned char *) "1", 1, self.data.bytes);
    _data = newChainKey;
}

- (NACLSymmetricPrivateKey *) nextMessageKey
{
    NSMutableData *messageKeyData = [NSMutableData dataWithLength: [NACLSymmetricPrivateKey keyLength]];
    crypto_auth_hmacsha256(messageKeyData.mutableBytes, (unsigned char *) "0", 1, self.data.bytes);
    NACLSymmetricPrivateKey *messageKey = [NACLSymmetricPrivateKey keyWithData: messageKeyData];
    
    [self nextChainKey];
    
    return messageKey;
}

#pragma mark NSCoding

#define kMOBAxolotlChainKeyDataKey @"data"

- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: _data forKey: kMOBAxolotlChainKeyDataKey];
}

- (id)initWithCoder: (NSCoder *) coder
{
    return [self initWithKeyData: [coder decodeObjectForKey: kMOBAxolotlChainKeyDataKey]];
}
@end
