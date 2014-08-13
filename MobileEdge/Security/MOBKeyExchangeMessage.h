//
//  MOBKeyExchangeMessage.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/11/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

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
