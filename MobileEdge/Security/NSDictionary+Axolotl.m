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

#import "NSDictionary+Axolotl.h"
#import "MOBAxolotl.h"

@implementation NSDictionary (Axolotl)

- (NSData *) decryptedDataFromSender: (MOBRemoteIdentity *) aRemoteIdentity
                         withAxolotl: (MOBAxolotl *) aAxolotl
{
    return [aAxolotl decryptBody: self[@"body"]
                        withHead: self[@"head"]
                       withNonce: self[@"nonce"]];
}

@end
