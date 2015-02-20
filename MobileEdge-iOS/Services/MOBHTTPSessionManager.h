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
 * Created by Raphael Arias on 01/14/15.
 */

#import "AFHTTPSessionManager.h"
#import "MOBProtocol.h"

@class  MOBCore, MOBIdentity, MOBRemoteIdentity;

typedef void (^DataTaskCompletionHandler) (NSURLResponse *response, id responseObject, NSError *error);

/**
 * Subclass of AFHTTPSessionManager that behaves the same, except that
 * it uses our Anonymizer and Protocol to route and encrypt requests.
 * Transparently performs the key exchange with remotes if possible.
 * 
 * This is achieved by using the session configuration suitable for
 * CPAProxy after connecting to Tor. This is probably the
 * most suitable interface, also for other anonymizing networks that should
 * be integrated.
 *
 * In order to integrate the encryption behaviour into the Session,
 * we need to change the behaviour of the standard methods.
 * According to http://cocoadocs.org/docsets/AFNetworking/2.3.1/Classes/AFHTTPSessionManager.html
 * this is best done by overriding the method dataTaskWithRequest:completionHandler,
 * which is called by all the convenience functions of AFHTTPSessionManager.
 * 
 * Architeturally it is probably best if a single SessionManager per local
 * Identity is shared across the application. We will thus keep track of current
 * SessionManagers and return the correct one if managerWithIdentity is called,
 * rather than creating a new one.
 * 
 * This behaviour can also be used to relieve the application developer of
 * the task of creating the session themselves. Once connected to the anonymizer,
 * we can create a session manager for a remote ourselves (if the remote is known...).
 */
@interface MOBHTTPSessionManager : AFHTTPSessionManager

#pragma mark -
#pragma mark Properties

/**
 * @discussion The core object.
 */
@property (nonatomic, strong) MOBCore *core;
/**
 * @discussion Our own identity.
 */
@property (nonatomic, strong) MOBIdentity *myIdentity;

/**
 * @discussion The protocol object used for encryption and decryption.
 */
@property (nonatomic, strong) id<MOBProtocol> protocol;

#pragma mark -
#pragma mark Class methods

/**
 * @discussion Create and initialize a newly initialized MOBHTTPSessionManager.
 * This creates a new, fresh Identity. RemoteIdentities can be added manually,
 * later on.
 * @return a new MOBHTTPSessionManager
 */
+ (instancetype) manager;

/**
 * @discussion Create and initialize a SessionManager with a given local Identity.
 * Note that a remote identity needs to be added, before encryption can take place.
 * @param aMyIdentity - our own Identity.
 * @return the initialized SessionManager.
 */
+ (instancetype) managerWithIdentity: (MOBIdentity *) aMyIdentity;

/**
 * @discussion Return the default session configuration.
 * @return the default session configuration.
 */
+ (NSURLSessionConfiguration *) defaultSessionConfiguration;

/**
 * @discussion Set the default session configuration.
 * @param aConfiguration - the new default session configuration.
 */
+ (void) setDefaultSessionConfiguration: (NSURLSessionConfiguration *) aConfiguration;

/**
 * @discussion Clear the default session configuration.
 */
+ (void) clearDefaultSessionConfiguration;

#pragma mark -
#pragma mark Instance methods
/**
 * @discussion Initializes a SessionManager with a given local Identity.
 * Note that a remote identity needs to be added, before encryption can take place.
 * @param aMyIdentity - our own Identity.
 * @return the initialized SessionManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;

/**
 * @discussion Initializes a SessionManager with a given local Identity and a
 * session configuration. The session configuration is used to route traffic
 * through the anonymizer.
 * Note that a remote identity needs to be added, before encryption can take place.
 * @param aMyIdentity - our own Identity.
 * @param aConfiguration - the session configuration.
 * @return the initialized SessionManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
             sessionConfiguration: (NSURLSessionConfiguration *) aConfiguration;

/**
 * @discussion Initializes a SessionManager with a local and a remote
 * identity.
 * @param aMyIdentity - our own Identity.
 * @param aRemoteIdentity - the remote Identity.
 * @return the initialized SessionManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

/**
 * @discussion Initializes a SessionManager with a local identity, a remote
 * identity, and a session configuration. The session configuration is used to 
 * route traffic through the anonymizer.
 * @param aMyIdentity - our own Identity.
 * @param aRemoteIdentity - the remote Identity.
 * @param aConfiguration - the session configuration.
 * @return the initialized SessionManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity
             sessionConfiguration: (NSURLSessionConfiguration *) aConfiguration;

/**
 * @discussion Initializes a SessionManager. As no own identity is given,
 * a new one is created.
 * @return the initialized SessionManager.
 */
- (instancetype) init;

/**
 * @discussion Initializes a SessionManager with a remote identity. A
 * local new one is created, as none is given.
 * @param aRemoteIdentity - the remote Identity.
 * @return the initialized SessionManager.
 */
- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

/**
 * @discussion Adds a remote identity to the SessionManager.
 * @param aRemoteIdentity - the remote Identity.
 */
- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;




@end
