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

#import <Foundation/Foundation.h>

@interface MOBKeyExchangeMessage : NSObject

@property (nonatomic, strong, readonly) NSData *identityKey;
@property (nonatomic, strong, readonly) NSData *ephemeralKey0;
@property (nonatomic, strong, readonly) NSData *ephemeralKey1;

- (instancetype) initWithAlicesIdentityKey: (NSData *) aIdentityKey
                             ephemeralKey0: (NSData *) aEphemeralKey0;

- (instancetype) initWithBobsIdentityKey: (NSData *) aIdentityKey
                           ephemeralKey0: (NSData *) aEphemeralKey0
                           ephemeralKey1: (NSData *) aEphemeralKey1;

@end
