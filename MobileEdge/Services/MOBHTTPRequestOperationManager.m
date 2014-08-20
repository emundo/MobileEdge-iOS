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
typedef void (^RequestOperationOnSuccessBlock) ( AFHTTPRequestOperation *operation, id responseObject );
typedef void (^RequestOperationOnFailureBlock) ( AFHTTPRequestOperation *operation, NSError *error );

- (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest: (NSURLRequest *) request
                                                     success: (void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                                                     failure: (void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) failure
{
    //TODO perform protocol cleaning
    //TODO perform key exchanges/encryption if necessary and possible
    // We keep a dictionary of URLs and can check, whether a request URL is part of that list.
    // If it is, we call the axolotl subsystem
    MOBRemoteIdentity *remoteIdentity;
    if ((remoteIdentity = self.remotes[request.URL.absoluteString]))
    {
        MOBAxolotl *axolotl;
        axolotl = [[MOBAxolotl alloc] initWithIdentity: self.myIdentity];
        
        __block AFHTTPRequestOperation *keyExchangeRequestOperation;
        KeyExchangeSendBlock sendBlock;
        sendBlock = ^(NSData *keyExchangeMessageOut, KeyExchangeFinalizeBlock finalizeBlock)
        {
            RequestOperationOnSuccessBlock onSuccessfulKeyExchange;
            RequestOperationOnFailureBlock onFailedKeyExchange;
            
            RequestOperationOnSuccessBlock onSuccessfulEncryptedRequest;
            RequestOperationOnFailureBlock onFailedEncryptedRequest;
            onSuccessfulEncryptedRequest = ^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSMutableDictionary *decryptedResponseObject = [NSMutableDictionary dictionary];
                // When the encryption was successful and the server responds in a expected way,
                // the structure of the response should look as follows:
                // { "nonce" : ..., "head" : ..., "body": ... }
                [axolotl decryptMessage: (NSDictionary*) responseObject
                             fromSender:remoteIdentity];
                success(operation, decryptedResponseObject);
            };
            onFailedEncryptedRequest = ^(AFHTTPRequestOperation *operation, NSError *error)
            {
                
            };
            onSuccessfulKeyExchange = ^(AFHTTPRequestOperation *operation, id responseObject)
            {
                // When the key exchange was successful and the server responds in a expected way,
                // the structure of the response should look as follows:
                // { "message" : { "id" : ..., "eph0" : ..., "eph1" : ... } }
                finalizeBlock(responseObject[@"message"]);
                NSData *encryptedData = [axolotl encryptData:request.HTTPBody forRecipient: remoteIdentity];
                NSMutableURLRequest *newRequest = [request mutableCopy]; //[NSMutableURLRequest requestWithURL:request.URL];
                [newRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [newRequest setHTTPMethod:@"POST"];
                [newRequest setHTTPBody: encryptedData];
                
                AFHTTPRequestOperation *encryptedRequest = [super HTTPRequestOperationWithRequest:newRequest success:success failure:failure];
                [encryptedRequest start];
            };
            onFailedKeyExchange = ^(AFHTTPRequestOperation *operation, NSError *error)
            {
                DDLogError(@"No key exchange possible with %@ (Error:%@)", request.URL, error);
                // actually call the failure block passed to us!
                // Not doing so and defaulting back to unencrypted data opens up security vulnerabilites!
                //[super HTTPRequestOperationWithRequest:request success:success failure:failure];
                failure(keyExchangeRequestOperation, [NSError errorWithDomain:@"MOBKeyExchangeFailure" code:-1 userInfo:nil]);
            };
            
            //TODO request serialization using json?
            NSMutableURLRequest *keyExchangeRequest = [NSMutableURLRequest requestWithURL:request.URL];
            [keyExchangeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [keyExchangeRequest setHTTPMethod:@"POST"];
            [keyExchangeRequest setHTTPBody: keyExchangeMessageOut];
            keyExchangeRequestOperation =
                [super HTTPRequestOperationWithRequest: keyExchangeRequest
                                               success: onSuccessfulKeyExchange
                                               failure: onFailedKeyExchange];
            //[super POST: request.URL.absoluteString
              //                             parameters:keyExchangeMessageOut
            // TODO: register for changes to this operation
            [keyExchangeRequestOperation addObserver: self
                                          forKeyPath: @"responseSerializer"
                                             options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                             context: NULL];
            //TODO: further implement method!
        };
        [axolotl performKeyExchangeWithBob:remoteIdentity
            andSendKeyExchangeMessageUsing:sendBlock];
        return keyExchangeRequestOperation;
    }
    else
    {
        return [super HTTPRequestOperationWithRequest:request success:success failure:failure];
    }
}

- (void)observeValueForKeyPath: (NSString *) keyPath
                      ofObject: (id) object
                        change: (NSDictionary *) change
                       context: (void *) context
{
    if ([keyPath isEqual:@"responseSerializer"]) {
        AFHTTPRequestOperation *operation = object;
        
        change[NSKeyValueChangeNewKey]; //TODO do something with it
        change[NSKeyValueChangeOldKey]; //TODO do something with it
        
    }
    
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
    /*
     [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
     */
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
