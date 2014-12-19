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
 * Created by Raphael Arias on 8/13/14.
 */

#import "AFHTTPRequestOperationManager.h"

@class MOBIdentity, MOBRemoteIdentity, MOBCore;

typedef void (^RequestOperationOnSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^RequestOperationOnFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);


/**
 * Subclass of AFHTTPRequestOperationManager that behaves the same, except that
 * it uses our Anonymizer and Protocol to route and encrypt requests.
 * Transparently performs the key exchange with remotes if possible.
 */
@interface MOBHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic, strong) MOBCore *core;
/**
 * @discussion Our own identity.
 */
@property (nonatomic, strong) MOBIdentity *myIdentity;
/**
 * @discussion We should anonymize requests.
 */
@property (nonatomic, assign) BOOL shouldAnonymize;

/**
 * @discussion Initializes a RequestOperationManager with a given local Identity.
 * Note that a remote identity needs to be added, before encryption can take place.
 * @param aMyIdentity - our own Identity.
 * @return the initialized RequestOperationManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity;

/**
 * @discussion Initializes a RequestOperationManager with a local and a remote
 * identity.
 * @param aMyIdentity - our own Identity.
 * @param aRemoteIdentity - the remote Identity.
 * @return the initialized RequestOperationManager.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) aMyIdentity
                   remoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

/**
 * @discussion Initializes a RequestOperationManager. As no own identity is given,
 * a new one is created.
 * @return the initialized RequestOperationManager.
 */
- (instancetype) init;

/**
 * @discussion Initializes a RequestOperationManager with a remote identity. A
 * local new one is created, as none is given.
 * @param aRemoteIdentity - the remote Identity.
 * @return the initialized RequestOperationManager.
 */
- (instancetype) initWithRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

/**
 * @discussion Adds a remote identity to the RequestOperationManager.
 * @param aRemoteIdentity - the remote Identity.
 */
- (void) addRemoteIdentity: (MOBRemoteIdentity *) aRemoteIdentity;

@end
