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

#import "MOBHTTPRequestOperationManager.h"
#import "MOBRemoteIdentity.h"

@interface MOBHTTPRequestOperationManager ()

@property (nonatomic,strong) NSMutableDictionary *remotes;

@end



@implementation MOBHTTPRequestOperationManager

- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (self = [super init])
    {
        self.shouldUseTor = YES;
        [self addRemoteIdentity:aRemoteIdentity];
    }
    return self;
}

- (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest: (NSURLRequest *) request
                                                     success: (void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                                                     failure: (void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) failure
{
    //TODO perform key exchanges/encryption if necessary and possible
    // options to achieve this:
    // * check whether the target domain/IP supports MobileEdge by keeping a list of domains
    // *
    //TODO perform protocol cleaning
    return [super HTTPRequestOperationWithRequest:request success:success failure:failure];
}


- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (!self.remotes) {
        self.remotes = [NSMutableDictionary dictionary];
    }
    [self.remotes setObject:aRemoteIdentity forKey: aRemoteIdentity.serviceURL];
}

- (void) setShouldUseTor: (BOOL) aShouldUseTor
{
    if (aShouldUseTor)
    {
        //TODO register class
        _shouldUseTor = YES;
    }
    else
    {
        //TODO unregister class
        _shouldUseTor = NO;
    }
}

@end
