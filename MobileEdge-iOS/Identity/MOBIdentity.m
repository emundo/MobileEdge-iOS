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

@interface MOBIdentity ()

@property (nonatomic, strong) NSString *base64;

@end


@implementation MOBIdentity

-(instancetype) init
{
    NACLAsymmetricKeyPair *newKeyPair = [NACLAsymmetricKeyPair keyPair];
    return [self initWithKeyPair: newKeyPair];
}

-(instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
{
    if (self = [super initWithPublicKey:aKeyPair.publicKey])
    {
        _identityKeyPair = aKeyPair;
        _creationDate = [NSDate date];
    }
    return self;
}

- (NSString *) base64
{
    if (!_base64)
    {
        _base64 = [self.identityKeyPair.publicKey.data base64EncodedStringWithOptions: 0];
    }
    return _base64;
}

#pragma mark -
#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
    MOBIdentity *copy = [super copyWithZone:zone];
    copy->_identityKeyPair = [self.identityKeyPair copyWithZone: zone];
    copy->_creationDate = [self.creationDate copyWithZone: zone];
    copy.ttl = [self.ttl copyWithZone: zone];
    copy.comment = [self.comment copyWithZone: zone];
    return copy;
}

#pragma mark NSCoding
- (void) encodeWithCoder: (NSCoder *) encoder
{
    [super encodeWithCoder: encoder];
    [encoder encodeObject: self.identityKeyPair forKey: kMOBIdentityKeyPairKey];
    [encoder encodeObject: self.creationDate forKey: kMOBIdentityCreationDateKey];
    if (self.ttl)
    {
        [encoder encodeObject: self.ttl forKey: kMOBIdentityTTLKey];
    }
    if (self.comment)
    {
        [encoder encodeObject: self.comment forKey: kMOBIdentityTTLKey];
    }
}

- (id)initWithCoder: (NSCoder *) coder
{
    if ( (self = [super initWithCoder: coder]) )
    {
        _identityKeyPair = [coder decodeObjectForKey: kMOBIdentityKeyPairKey];
        _creationDate = [coder decodeObjectForKey: kMOBIdentityCreationDateKey];
        self.ttl = [coder decodeObjectForKey: kMOBIdentityTTLKey];
        self.comment = [coder decodeObjectForKey: kMOBIdentityCommentKey];
    }
    return self;
}



@end
