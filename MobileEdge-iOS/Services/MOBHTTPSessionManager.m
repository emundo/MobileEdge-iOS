/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
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
 * Created by Raphael Arias on 2015-01-14.
 */


#import "MOBHTTPSessionManager.h"
#import "MOBCore.h"

static NSMutableDictionary *managersByIdentity = nil;
static NSURLSessionConfiguration *defaultConfiguration = nil;

@interface MOBHTTPSessionManager ()

@property (nonatomic, strong) NSMutableDictionary *remotes;
@property (nonatomic, strong) id <AFURLResponseSerialization> clientResponseSerializer;

@end

@implementation MOBHTTPSessionManager

#pragma mark -
#pragma mark Class methods

+ (instancetype) manager
{
    return [[[self class] alloc] init];
}

+ (instancetype) managerWithIdentity: (MOBIdentity *) aMyIdentity
{
    MOBHTTPSessionManager *manager = nil;
    if ((manager = managersByIdentity[[aMyIdentity base64]]))
    {
        return manager;
    }
    if (!managersByIdentity)
    {
        managersByIdentity = [[NSMutableDictionary alloc] initWithCapacity: 1];
    }
        
    manager = [[[self class] alloc] initWithIdentity: aMyIdentity];
    managersByIdentity[[aMyIdentity base64]] = manager;
    return manager;
}

+ (void) setDefaultSessionConfiguration: (NSURLSessionConfiguration *) aConfiguration
{
    defaultConfiguration = aConfiguration;
}

+ (void) clearDefaultSessionConfiguration
{
    defaultConfiguration = nil;
}

+ (NSURLSessionConfiguration *) defaultSessionConfiguration
{
    return defaultConfiguration;
}

#pragma mark -
#pragma mark Instance methods
#pragma mark -
#pragma mark Initializers

- (instancetype) init
{
    if (self = [super initWithSessionConfiguration: defaultConfiguration])
    {
        self.myIdentity = [[MOBIdentity alloc] init];
        self.clientResponseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
             sessionConfiguration: (NSURLSessionConfiguration *) aConfiguration
{
    if (self = [super initWithSessionConfiguration: aConfiguration])
    {
        self.myIdentity = aMyIdentity;
        self.clientResponseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;
{
    if (self = [super initWithSessionConfiguration: defaultConfiguration])
    {
        self.myIdentity = aMyIdentity;
        self.clientResponseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
             sessionConfiguration: (NSURLSessionConfiguration *) aConfiguration
{
    if (self = [self initWithIdentity: aMyIdentity
                 sessionConfiguration: aConfiguration])
    {
        [self addRemoteIdentity: aRemoteIdentity];
    }
    return self;
}

- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (self = [self initWithIdentity: aMyIdentity])
    {
        [self addRemoteIdentity: aRemoteIdentity];
    }
    return self;
}

- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (self = [self init])
    {
        [self addRemoteIdentity: aRemoteIdentity];
    }
    return self;
}

#pragma mark -
#pragma mark Overrides

- (NSURLSessionDataTask *) dataTaskWithRequest: (NSURLRequest *) request
                             completionHandler: (DataTaskCompletionHandler) completionHandler
{
    // send over anonymized connection
    
    // We keep a dictionary of URLs and can check, whether a request URL is part of that list.
    // If it is, we call the axolotl subsystem
    MOBRemoteIdentity *remoteIdentity;
    if (!(remoteIdentity = self.remotes[request.URL.absoluteString]))
    { // We have no remote matching this URL, proceed without key exchange or encryption.
        return [super dataTaskWithRequest: request
                        completionHandler: completionHandler];
    }
    
    // We do have a matching remote. Prepare for sending an encrypted request.
    id <MOBProtocol> axolotl;
    axolotl = [MOBAxolotl cachedProtocolForIdentity: self.myIdentity];
   
    
    // if a key exchange needs to be performed, handle success and failure:
    __block DataTaskCompletionHandler keyExchangeCompletionHandler;
    
    // handle success and failure of encrypted request:
    DataTaskCompletionHandler encryptedRequestCompletionHandler;
    
    // create a new completionHandler that decrypts the answer.
    encryptedRequestCompletionHandler = ^(NSURLResponse *response, id responseObject, NSError *error)
    {
        [self handleRequestCompletionWithResponse: response
                                   responseObject: responseObject
                                            error: error
                               fromRemoteIdentity: remoteIdentity
                                     withProtocol: axolotl
                                completionHandler: completionHandler];
    };
    
    if ([axolotl hasSessionForRemote: remoteIdentity])
    { // just encrypt, a session is present.
        return [self encryptAndSendRequest: request
                                  toRemote: remoteIdentity
                              withProtocol: axolotl
                         completionHandler: encryptedRequestCompletionHandler];
    }

    __block NSURLSessionDataTask *dataTask = nil;
    KeyExchangeSendBlock sendBlock;
    
    sendBlock = ^(NSDictionary *keyExchangeMessageOut, KeyExchangeFinalizeBlock finalizeBlock)
    {
        keyExchangeCompletionHandler = ^(NSURLResponse *response, id responseObject, NSError *error)
        {
            [self handleKeyExchangeCompletionWithResponse: response
                                           responseObject: responseObject
                                                    error: error
                                       fromRemoteIdentity: remoteIdentity
                                             withProtocol: axolotl
                                                  request: request
                                            finalizeBlock: finalizeBlock
                                        completionHandler: encryptedRequestCompletionHandler];
        };
        dataTask = [self sendKeyExchangeMessage: keyExchangeMessageOut
                                     forRequest: request
                              completionHandler: keyExchangeCompletionHandler];
    };
    NSError *error = nil;
    [axolotl performKeyExchangeWithBob: remoteIdentity
        andSendKeyExchangeMessageUsing: sendBlock
                                 error: &error];
    if (error)
    {
        DDLogError(@"Error occurred during key exchange: %@ %@", error, error.userInfo);
        completionHandler(nil, nil, error);
    }
    return dataTask;
}

#pragma mark -
#pragma mark Helper methods

//- (NSURL *) extendURL: (NSURL*) url
//           withRemote: (MOBRemoteIdentity *) remote
//{
//    NSURL *result = [NSURL URLWithString: [url path] relativeToURL: remote.serviceURL];
//    return result;
//}

- (NSURLSessionDataTask *) sendKeyExchangeMessage: (NSDictionary *) keyExchangeMessageOut
                                       forRequest: (NSURLRequest *) request
                                completionHandler: (DataTaskCompletionHandler) completionHandler
{
    NSError *error = nil;
    NSDictionary *keyExchangeMessageWrapper = [NSDictionary dictionaryWithObjectsAndKeys: @"KEYXC", @"type", keyExchangeMessageOut, @"keys", nil];
    NSData *keyExchangeDataOut = [NSJSONSerialization dataWithJSONObject: keyExchangeMessageWrapper
                                                                 options: 0
                                                                   error: &error];
    if (error)
    {
        DDLogError(@"Error while serializing key exchange message: %@ %@", error, error.userInfo);
        completionHandler(nil, nil, error);
        return nil;
    }
    
    
    NSMutableURLRequest *keyExchangeRequest = [NSMutableURLRequest requestWithURL: request.URL];
    [keyExchangeRequest setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [keyExchangeRequest setHTTPMethod: @"POST"];
    [keyExchangeRequest setHTTPBody: keyExchangeDataOut];
    return [super dataTaskWithRequest: keyExchangeRequest
                    completionHandler: completionHandler];
}
- (NSURLSessionDataTask *) encryptAndSendRequest: (NSURLRequest *) aRequest
                                        toRemote: (MOBRemoteIdentity *) aRemoteIdentity
                                    withProtocol: (id<MOBProtocol>) aProtocol
                               completionHandler: (DataTaskCompletionHandler) aCompletionHandler
{
    NSError *error = nil;
    NSDictionary *encryptedMessage = [aProtocol encryptData: aRequest.HTTPBody
                                               forRecipient: aRemoteIdentity
                                                      error: &error];
    NSMutableDictionary *mutMessage = [NSMutableDictionary dictionaryWithDictionary:encryptedMessage];
    mutMessage[@"type"] = @"CRYPT";
    //NSDictionary *messageWrapper = @{
    //                                 @"type" : @"CRYPT",
    //                                 @"payload" : mutMessage
    //                                 };
    if (error)
    {
        DDLogError(@"Error during encryption: %@ %@", error, error.userInfo);
        aCompletionHandler(nil, nil, error);
        return nil;
    }
    NSData *encryptedData = [NSJSONSerialization dataWithJSONObject: mutMessage
                                                            options: 0
                                                              error: &error];
    if (error)
    {
        DDLogError(@"Error while serializing encrypted message: %@ %@", error, error.userInfo);
        aCompletionHandler(nil, nil, error);
        return nil;
    }
    NSMutableURLRequest *newRequest = [aRequest mutableCopy];
    
    [newRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [newRequest setHTTPMethod:@"POST"];
    [newRequest setHTTPBody: encryptedData];
    
    return [super dataTaskWithRequest: newRequest completionHandler: aCompletionHandler ];
}

- (void) handleRequestCompletionWithResponse: (NSURLResponse *) response
                              responseObject: (id) responseObject
                                       error: (NSError *) error
                          fromRemoteIdentity: (MOBRemoteIdentity *) remoteIdentity
                                withProtocol: (id <MOBProtocol>) axolotl
                           completionHandler: (DataTaskCompletionHandler) completionHandler
{
    DDLogDebug(@"Handling request completion");
    if (error)
    { // An error occurred during the request.
        //TODO: check if this is a server side error that can be handled here.
        DDLogError(@"Completion error: %@ %@", error, error.userInfo);
        completionHandler(response, nil, error);
        return;
    }
    NSMutableDictionary *decryptedResponseObject = [NSMutableDictionary dictionary];
    NSError *decryptionError = nil;
    // When the encryption was successful and the server responds in an expected way,
    // the structure of the response should look as follows:
    // { "nonce" : ..., "head" : ..., "body": ... }
    NSDictionary *encryptedMessage = responseObject;
    NSData *decryptedData = [encryptedMessage decryptedDataFromSender: remoteIdentity
                                                         withProtocol: axolotl
                                                                error: &decryptionError];
    if (decryptionError)
    { // There was an error during decryption. Hand this back to the client.
        DDLogError(@"Decryption error: %@ %@", decryptionError, decryptionError.userInfo);
        completionHandler(response, nil, decryptionError);
        return;
    }
    
    NSError *serializationError = nil;
    decryptedResponseObject = [self.clientResponseSerializer responseObjectForResponse: response
                                                                                  data: decryptedData
                                                                                 error: &serializationError];
    DDLogDebug(@"Received: %@", decryptedResponseObject);
    completionHandler(response, decryptedResponseObject, serializationError);
}

- (void) handleKeyExchangeCompletionWithResponse: (NSURLResponse *) response
                                  responseObject: (id) responseObject
                                           error: (NSError *) error
                              fromRemoteIdentity: (MOBRemoteIdentity *) remoteIdentity
                                    withProtocol: (id <MOBProtocol>) axolotl
                                         request: (NSURLRequest *) request
                                   finalizeBlock: (KeyExchangeFinalizeBlock) finalizeBlock
                               completionHandler: (DataTaskCompletionHandler) completionHandler
{
    DDLogDebug(@"Handling key exchange completion");
    if (error)
    { // An error occurred during the key exchange request.
        //TODO: check if this is a server side error that can be handled here.
        DDLogError(@"Completion error: %@ %@", error, error.userInfo);
        completionHandler(response, nil, error);
        return;
    }
    // When the key exchange was successful and the server responds in an expected way,
    // the structure of the response should look as follows:
    // { "message" : { "id" : ..., "eph0" : ..., "eph1" : ... } }
    finalizeBlock(responseObject);
    NSURLSessionDataTask *dataTask = [self encryptAndSendRequest: request
                                                        toRemote: remoteIdentity
                                                    withProtocol: axolotl
                                               completionHandler: completionHandler];
    [dataTask resume];
}

#pragma mark -
#pragma mark Settings

- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
{
    if (!self.remotes) {
        self.remotes = [NSMutableDictionary dictionary];
    }
    [self.remotes setObject: aRemoteIdentity forKey: aRemoteIdentity.serviceURL.absoluteString];
}

@end
