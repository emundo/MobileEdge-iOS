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

#import "MOBAxolotlSkippedKeyRing.h"

@implementation MOBAxolotlSkippedKeyRing

- (instancetype) initWithMessageKeys: (NSMutableArray *) aMessageKeys
                        forHeaderKey: (NACLSymmetricPrivateKey *) aHeaderKey
{
    if (self = [super init])
    {
        _headerKey = aHeaderKey;
        _messageKeys = aMessageKeys;
    }
    return self;
}
@end
