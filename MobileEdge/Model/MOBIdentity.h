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

@interface MOBIdentity : NSObject

@property (nonatomic, retain) NSString *ttl;
@property (nonatomic, retain) NSString *nonce;
@property (nonatomic, retain) NSString *mac;
@property (nonatomic, retain) NSString *creationDate;

@end
