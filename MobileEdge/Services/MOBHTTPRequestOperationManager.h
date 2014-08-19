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

#import "AFHTTPRequestOperationManager.h"

@class MOBIdentity, MOBRemoteIdentity;

@interface MOBHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic,strong) MOBIdentity *myIdentity;
@property (nonatomic,assign) BOOL shouldUseTor;


- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

- (instancetype) init;

- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

@end
