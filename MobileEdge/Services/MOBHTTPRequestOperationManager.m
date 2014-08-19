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
#import "MOBIdentity.h"
#import "MOBAxolotl.h"
#import "MOBCore.h"

@interface MOBHTTPRequestOperationManager ()

@property (nonatomic,strong) NSMutableDictionary *remotes;

@end



@implementation MOBHTTPRequestOperationManager

#pragma mark -
#pragma mark Initializers

- (instancetype) init
{
    if (self = [super init])
    {
        self.shouldUseTor = YES;
        self.myIdentity = [[MOBIdentity alloc] init];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;
{
    if (self = [super init])
    {
        self.shouldUseTor = YES;
        self.myIdentity = aMyIdentity;
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                    remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (self = [self initWithIdentity:aMyIdentity])
    {
        [self addRemoteIdentity:aRemoteIdentity];
    }
    return self;
}

- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (self = [self init])
    {
        [self addRemoteIdentity:aRemoteIdentity];
    }
    return self;
}

#pragma mark -
#pragma mark Overrides for inherited methods

- (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest: (NSURLRequest *) request
                                                     success: (void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                                                     failure: (void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) failure
{
    //TODO perform key exchanges/encryption if necessary and possible
    // We keep a dictionary of URLs and can check, whether a request URL is part of that list.
    // If it is, we call the axolotl subsystem
    MOBRemoteIdentity *remoteIdentity;
    if ((remoteIdentity = self.remotes[request.URL.absoluteString]))
    {
        MOBAxolotl *axolotl;
        axolotl = [[MOBAxolotl alloc] initWithIdentity: self.myIdentity];
        KeyExchangeSendBlock sendBlock;
        sendBlock = ^(NSData *keyExchangeMessageOut, KeyExchangeFinalizeBlock finalizeBlock)
        {
            //TODO request serialization using json?
            [super POST: request.URL.absoluteString
             parameters:keyExchangeMessageOut
                success:^(AFHTTPRequestOperation *operation, id responseObject)
                {
                    finalizeBlock(responseObject);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                {
                    DDLogError(@"No key exchange possible with %@ (Error:%@)", request.URL, error);
                }];
        };
        // encrypt the HTTP request (or transparently perform key agreement)
        [axolotl performKeyExchangeWithBob:remoteIdentity
            andSendKeyExchangeMessageUsing:sendBlock];
        NSData *encryptedData = [axolotl encryptData:request.HTTPBody forReceiver:remoteIdentity];
    }
    //TODO perform protocol cleaning
    return [super HTTPRequestOperationWithRequest:request success:success failure:failure];
}

#pragma mark -
#pragma mark Settings

- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (!self.remotes) {
        self.remotes = [NSMutableDictionary dictionary];
    }
    [self.remotes setObject:aRemoteIdentity forKey: aRemoteIdentity.serviceURL.absoluteString];
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
