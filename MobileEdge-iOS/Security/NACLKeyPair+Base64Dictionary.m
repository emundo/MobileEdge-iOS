/*
 * Copyright (c) 2015 eMundo
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo.
 *
 * Created by Raphael Arias on 24/02/15.
 */

#import "NACLKeyPair+Base64Dictionary.h"
#import "NACLKey+Base64.h"

@implementation NACLKeyPair (Base64Dictionary)

- (NSDictionary *) base64Dictionary
{
    return @{
             @"privateKey" : [self.privateKey base64],
             @"publicKey" : [self.publicKey base64]
             };
}

@end
