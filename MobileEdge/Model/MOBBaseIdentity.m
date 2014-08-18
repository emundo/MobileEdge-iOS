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

- (id) copyWithZone:(NSZone *)zone
{
    return [[MOBBaseIdentity alloc] initWithPublicKey: self.identityKey];
}

@end
