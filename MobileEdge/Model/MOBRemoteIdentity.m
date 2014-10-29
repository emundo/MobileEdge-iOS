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

#import "MOBRemoteIdentity.h"

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
    return [self.identityKey.data base64EncodedStringWithOptions: 0];
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
