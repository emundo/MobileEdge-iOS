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

#import <Foundation/Foundation.h>
#import <SodiumObjc.h>

#define kMOBBaseIdentityIdentityKey @"identityKey"

@interface MOBBaseIdentity : NSObject <NSCopying, NSCoding>

@property (nonatomic,strong) NACLAsymmetricPublicKey *identityKey;

- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey;

@end
