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
#import <SodiumObjc.h>
#import <sodium/crypto_scalarmult.h>
#import "MOBCore.h"

@implementation NACLKey (ScalarMult)

- (instancetype) multWithKey: (NACLKey *) aKey
{
    DDLogVerbose(@"%lu == %lu  == %lu ?", crypto_scalarmult_bytes(),
                 crypto_scalarmult_scalarbytes(), (unsigned long)[NACLKey keyLength]);
    NSMutableData *data = [NSMutableData dataWithLength: 32];
    unsigned char *target = data.mutableBytes;
    crypto_scalarmult(target, self.data.bytes, aKey.data.bytes);
    NACLKey *result = [[[self class] alloc] initWithData: data];
    return result;
}

@end
