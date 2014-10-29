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

#define kMOBRemoteIdentityServiceURLKey @"serviceURL"

@interface MOBRemoteIdentity : MOBBaseIdentity

@property (nonatomic, strong) NSURL *serviceURL;

- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
                        serviceURL: (NSURL *) aServiceURL;

- (NSString *) base64;

@end
