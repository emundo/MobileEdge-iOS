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

#import "MOBBaseIdentity.h"

#define kMOBRemoteIdentityServiceURLKey @"serviceURL"

/**
 * A Class to represent a remote identity. This is a Identity where we don't
 * know the private key. We might know some additional information, like 
 * a service URL (a URL through which to contact the remote).
 */
@interface MOBRemoteIdentity : MOBBaseIdentity

/**
 * @discussion A service URL to contact the remote Identity.
 */
@property (nonatomic, strong) NSURL *serviceURL;

/**
 * @discussion Initialize a remote identity with a given public key and a service
 * URL.
 * @param aPublicKey - the remote's public key
 * @param aServiceURL - the remote's service URL
 * @return the initialized remote identity
 */
- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
                        serviceURL: (NSURL *) aServiceURL;

/**
 * @discussion A convenience method to obtain the base64 string representation
 * of the public key.
 * @return the base64 representation of the public key
 */
- (NSString *) base64;

@end
