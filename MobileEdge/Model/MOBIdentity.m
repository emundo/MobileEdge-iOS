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
 * Created by Luca Müller on 7/30/14.
 */

#import "MOBIdentity.h"

@implementation MOBIdentity

-(instancetype) init
{
    NACLAsymmetricKeyPair *newKeyPair = [NACLAsymmetricKeyPair keyPair];
    if (self = [super initWithPublicKey:newKeyPair.publicKey])
    {
        _identityKeyPair = newKeyPair;
    }
    return self;
}

-(instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
{
    if (self = [super initWithPublicKey:aKeyPair.publicKey])
    {
        _identityKeyPair = aKeyPair;
    }
    return self;
}

/*
 * No support for NSCopying!
 */
#pragma mark -
#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
    MOBIdentity *copy = [super copyWithZone:zone];
    copy->_identityKeyPair = [self.identityKeyPair copyWithZone: zone];
    return copy;
}

#pragma mark NSCoding
- (void) encodeWithCoder: (NSCoder *) encoder
{
    [super encodeWithCoder: encoder];
    [encoder encodeObject: _identityKeyPair forKey: kMOBIdentityKeyPairKey];
}

- (id)initWithCoder: (NSCoder *) coder
{
    if ( (self = [super initWithCoder: coder]) )
    {
        _identityKeyPair = [coder decodeObjectForKey: kMOBIdentityKeyPairKey];
    }
    return self;
}



@end
