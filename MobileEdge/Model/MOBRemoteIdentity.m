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
    self = [super initWithPublicKey:aPublicKey];
    self.serviceURL = aServiceURL;
    return self;
}

- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
                        serviceURL: (NSURL *) aServiceURL
                identityServiceURL: (NSURL *) aIdentityServiceURL
{
    self = [super initWithPublicKey:aPublicKey];
    self.serviceURL = aServiceURL;
    self.identityServiceURL = aIdentityServiceURL;
    return self;
}

@end
