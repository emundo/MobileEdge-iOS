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
