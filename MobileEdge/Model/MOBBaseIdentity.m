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

#import "MOBBaseIdentity.h"

@implementation MOBBaseIdentity

- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
{
    if (self = [super init])
    {
        self.identityKey = aPublicKey;
    }
    return self;
}

#pragma mark -
#pragma mark NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    return [[MOBBaseIdentity alloc] initWithPublicKey: self.identityKey];
}

#pragma mark NSCoding


- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: _identityKey forKey: kMOBBaseIdentityIdentityKey];
}

- (id)initWithCoder: (NSCoder *) decoder
{
    NACLAsymmetricPublicKey *identityKey = [decoder decodeObjectForKey: kMOBBaseIdentityIdentityKey];
    return [self initWithPublicKey: identityKey];
}

@end
