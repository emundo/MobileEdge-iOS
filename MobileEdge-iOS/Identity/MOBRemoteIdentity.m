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

#import "MOBRemoteIdentity.h"
@interface MOBRemoteIdentity ()

@property (nonatomic, strong) NSString *base64;

@end

@implementation MOBRemoteIdentity


- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
                        serviceURL: (NSURL *) aServiceURL
{
    if (self = [super initWithPublicKey:aPublicKey])
    {
        self.serviceURL = aServiceURL;
    }
    return self;
}

- (NSString *) base64
{
    if (!_base64)
    {
        _base64 = [self.identityKey.data base64EncodedStringWithOptions: 0];
    }
    return _base64;
}

#pragma mark -
#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
    /* This is apparently how Apple recommends implementing it (with a super call):
    MOBRemoteIdentity *copy = [super copyWithZone:zone];
    copy.serviceURL = [self.serviceURL copy];
    return copy;
     
     // But that does not work as the copy does not have the necessary instance
     // variables and setters for them.
     */
    
    MOBRemoteIdentity *copy = [[[self class] alloc] initWithPublicKey: [self.identityKey copyWithZone: zone]
                                                           serviceURL: [self.serviceURL copyWithZone: zone]];
    // copy->_serviceURL = [self.serviceURL copyWithZone: zone];
    return copy;
}

#pragma mark NSCoding
- (void) encodeWithCoder: (NSCoder *) encoder
{
    [super encodeWithCoder: encoder];
    [encoder encodeObject: _serviceURL forKey: kMOBRemoteIdentityServiceURLKey];
}

- (id)initWithCoder: (NSCoder *) coder
{
    if ( (self = [super initWithCoder: coder]) )
    {
        self.serviceURL = [coder decodeObjectForKey: kMOBRemoteIdentityServiceURLKey];
    }
    return self;
}

@end
