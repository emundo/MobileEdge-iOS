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
 * Created by Luca Müller on 7/30/14.
 */

#import <Foundation/Foundation.h>
#import "MOBBaseIdentity.h"
#import <SodiumObjc.h>

@interface MOBIdentity : MOBBaseIdentity

@property (nonatomic, strong, readonly) NACLAsymmetricPrivateKey *privateIdentityKey;
@property (nonatomic, strong) NSString *ttl;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *creationDate;

-(instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair;

@end
