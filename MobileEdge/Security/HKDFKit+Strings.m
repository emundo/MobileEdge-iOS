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
 * Created by Raphael Arias on 04/11/14.
 */

#import "HKDFKit+Strings.h"

@implementation HKDFKit (Strings)
+ (NSData *) deriveKey: (NSData *) seed
            infoString: (NSString *) info
            saltString: (NSString *) salt
            outputSize: (int) outputSize
{
    return [HKDFKit deriveKey: seed
                         info: [info dataUsingEncoding: NSUTF8StringEncoding]
                         salt: [salt dataUsingEncoding: NSUTF8StringEncoding]
                   outputSize: outputSize];
}
@end
