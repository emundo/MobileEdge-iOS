/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This file is part of MobileEdge-iOS.
 * MobileEdge-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileEdge-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MobileEdge-iOS.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created by Raphael Arias on 8/13/14.
 */

#import "MOBHTTPRequestOperationManager.h"
#import "MOBRemoteIdentity.h"
#import "MOBIdentity.h"
#import "MOBAxolotl.h"
#import "MOBCore.h"
#import "NSDictionary+Protocol.h"

@interface MOBHTTPRequestOperationManager ()

@property (nonatomic,strong) NSMutableDictionary *remotes;
@property (nonatomic,strong) NSMutableDictionary *cachedResponseSerializers;

@end



@implementation MOBHTTPRequestOperationManager

#pragma mark -
#pragma mark Initializers

- (instancetype) init
{
    if (self = [super init])
    {
        self.shouldAnonymize = YES;
        self.myIdentity = [[MOBIdentity alloc] init];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;
{
    if (self = [super init])
    {
        self.shouldAnonymize = YES;
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
typedef void (^RequestOperationOnSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^RequestOperationOnFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

- (AFHTTPRequestOperation *) HTTPRequestOperationWithRequest: (NSURLRequest *) request
                                                     success: (void ( ^ ) (AFHTTPRequestOperation *operation, id responseObject)) success
                                                     failure: (void ( ^ ) (AFHTTPRequestOperation *operation, NSError *error)) failure
{
    //TODO perform protocol cleaning
    //TODO perform key exchanges/encryption if necessary and possible
    // We keep a dictionary of URLs and can check, whether a request URL is part of that list.
    // If it is, we call the axolotl subsystem
    MOBRemoteIdentity *remoteIdentity;
    if (!(remoteIdentity = self.remotes[request.URL.absoluteString]))
    {
        return [super HTTPRequestOperationWithRequest: request
                                              success: success
                                              failure: failure];
    }
    id <MOBProtocol> axolotl;
    axolotl = [[MOBAxolotl alloc] initWithIdentity: self.myIdentity];
    
    __block AFHTTPRequestOperation *keyExchangeRequestOperation;
    __block RequestOperationOnSuccessBlock onSuccessfulKeyExchange;
    RequestOperationOnFailureBlock onFailedKeyExchange;
    
    RequestOperationOnSuccessBlock onSuccessfulEncryptedRequest;
    RequestOperationOnFailureBlock onFailedEncryptedRequest;
    onSuccessfulEncryptedRequest = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSMutableDictionary *decryptedResponseObject = [NSMutableDictionary dictionary];
        // When the encryption was successful and the server responds in an expected way,
        // the structure of the response should look as follows:
        // { "nonce" : ..., "head" : ..., "body": ... }
        NSDictionary *encryptedMessage = responseObject;
        NSData *decryptedData = [encryptedMessage decryptedDataFromSender: remoteIdentity
                                                             withProtocol: axolotl
                                                                    error: nil];
        //[axolotl decryptMessage: responseObject
                                        //fromSender: remoteIdentity];
        // TODO: use client's responseSerializer if any!
        
        DDLogDebug(@"Received: %@", decryptedData);
        success(operation, decryptedResponseObject);
    };
    onFailedEncryptedRequest = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        // When the operation fails at the MobileEdge service we get an object back
        // that looks as follows:
        // { "errCode" : ..., "errMsg": ..., "errDevMsg" }
        DDLogError(@"Encrypted request to %@ failed (Error:%@)", request.URL, error);
        failure(keyExchangeRequestOperation, [NSError errorWithDomain:@"MOBEncryptedRequestFailure" code:-1 userInfo:nil]);
    };

    onFailedKeyExchange = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        DDLogError(@"No key exchange possible with %@ (Error:%@)", request.URL, error);
        // actually call the failure block passed to us!
        // Not doing so and defaulting back to unencrypted data opens up security vulnerabilites!
        //[super HTTPRequestOperationWithRequest:request success:success failure:failure];
        failure(keyExchangeRequestOperation, [NSError errorWithDomain:@"MOBKeyExchangeFailure" code:-1 userInfo:nil]);
    };
    
    KeyExchangeSendBlock sendBlock;
    sendBlock = ^(NSDictionary *keyExchangeMessageOut, KeyExchangeFinalizeBlock finalizeBlock)
    {
        onSuccessfulKeyExchange = ^(AFHTTPRequestOperation *operation, id responseObject)
        {
            // When the key exchange was successful and the server responds in an expected way,
            // the structure of the response should look as follows:
            // { "message" : { "id" : ..., "eph0" : ..., "eph1" : ... } }
            finalizeBlock(responseObject[@"message"]);
            NSDictionary *encryptedMessage = [axolotl encryptData: request.HTTPBody
                                                     forRecipient: remoteIdentity
                                                            error: nil]; // TODO: error handling
            NSData *encryptedData = [NSJSONSerialization dataWithJSONObject: encryptedMessage
                                                                    options: 0
                                                                      error: nil]; // TODO: error handling
            NSMutableURLRequest *newRequest = [request mutableCopy]; //[NSMutableURLRequest requestWithURL:request.URL];
            
            [newRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [newRequest setHTTPMethod:@"POST"];
            [newRequest setHTTPBody: encryptedData];
            
            AFHTTPRequestOperation *encryptedRequest =
                [super HTTPRequestOperationWithRequest: newRequest
                                               success: onSuccessfulEncryptedRequest
                                               failure: onFailedEncryptedRequest];
            [encryptedRequest start];
        };
        //TODO request serialization using json?
        NSData *keyExchangeDataOut = [NSJSONSerialization dataWithJSONObject: keyExchangeMessageOut
                                                                     options: 0
                                                                       error: nil]; //TODO real error handling
        NSMutableURLRequest *keyExchangeRequest = [NSMutableURLRequest requestWithURL: request.URL];
        [keyExchangeRequest setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
        [keyExchangeRequest setHTTPMethod: @"POST"];
        [keyExchangeRequest setHTTPBody: keyExchangeDataOut];
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
    [axolotl performKeyExchangeWithBob: remoteIdentity
        andSendKeyExchangeMessageUsing: sendBlock
                                 error: nil]; // TODO: error handling
    return keyExchangeRequestOperation;
}

- (void) addCachedResponseSerializersObject: (AFHTTPResponseSerializer *) object
                                     forKey: (AFHTTPRequestOperation *) operation
{
    if (!self.cachedResponseSerializers)
    {
        self.cachedResponseSerializers = [NSMutableDictionary dictionaryWithCapacity: 1]; //dictionaryWithObject:object forKey:operation];
    }
    [self.cachedResponseSerializers setObject: object forKey:operation];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqual:@"responseSerializer"]) {
        [self addCachedResponseSerializersObject: change[NSKeyValueChangeNewKey]
                                          forKey: object];
        AFHTTPRequestOperation *operation = object;
        operation.responseSerializer = change[NSKeyValueChangeOldKey];
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

@end
