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
 * Created by Raphael Arias on 8/11/14.
 */

#import "MOBKeyExchangeMessage.h"

@implementation MOBKeyExchangeMessage

- (instancetype) initWithAlicesIdentityKey: (NSData *) aIdentityKey
                             ephemeralKey0: (NSData *) aEphemeralKey0
{
    _identityKey = aIdentityKey;
    _ephemeralKey0 = aEphemeralKey0;
    return self;
}

- (instancetype) initWithBobsIdentityKey: (NSData *) aIdentityKey
                           ephemeralKey0: (NSData *) aEphemeralKey0
                           ephemeralKey1: (NSData *) aEphemeralKey1
{
    _identityKey = aIdentityKey;
    _ephemeralKey0 = aEphemeralKey0;
    _ephemeralKey1 = aEphemeralKey1;
    return self;
}

@end
