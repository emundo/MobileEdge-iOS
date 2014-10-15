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
 * Created by Raphael Arias on 8/20/14.
 */

#import <Foundation/Foundation.h>
#import "MOBProtocol.h"

@class MOBRemoteIdentity;

@interface NSDictionary (Protocol)

- (NSData *) decryptedDataFromSender: (MOBRemoteIdentity *) aRemoteIdentity
                        withProtocol: (id <MOBProtocol>) aProtocol;

@end
