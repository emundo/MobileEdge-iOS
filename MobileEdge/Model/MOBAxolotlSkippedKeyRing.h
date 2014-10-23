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
 * Created by Raphael Arias on 22/10/14.
 */

#import <Foundation/Foundation.h>

@class NACLSymmetricPrivateKey;

@interface MOBAxolotlSkippedKeyRing : NSObject

@property (nonatomic, retain, readonly) NACLSymmetricPrivateKey *headerKey;
@property (nonatomic, retain, readonly) NSMutableArray *messageKeys;

- (instancetype) initWithMessageKeys: (NSMutableArray *) aMessageKeys
                        forHeaderKey: (NACLSymmetricPrivateKey *) aHeaderKey;


@end
