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
 * Created by Raphael Arias on 8/18/14.
 */

#import "NACLKey+ScalarMult.h"
#import <sodium/crypto_scalarmult.h>

@implementation NACLKey (ScalarMult)

- (instancetype) multWithKey: (NACLKey *) aKey
{
    NSMutableData *data = [NSMutableData dataWithLength:32];
    void *target = data.mutableBytes;
    crypto_scalarmult(target, self.data.bytes, aKey.data.bytes);
    NACLKey *result = [[NACLKey alloc] initWithData:data];
    return result;
}

@end
