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

@implementation MOBHTTPRequestOperationManager

- (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest: (NSURLRequest *) request
                                                     success: (void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                                                     failure: (void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) failure
{
    //TODO perform key exchanges/encryption if necessary and possible
    //TODO perform protocol cleaning
    return [super HTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (void) setShouldUseTor: (BOOL) shouldUseTor
{
    if (shouldUseTor)
    {
        //TODO register class
    }
    else
    {
        //TODO unregister class
    }
}

@end
