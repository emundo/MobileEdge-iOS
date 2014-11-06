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

@interface MOBRemoteIdentity : MOBBaseIdentity

@property (nonatomic, strong) NSURL *serviceURL;

- (instancetype) initWithPublicKey: (NACLAsymmetricPublicKey *) aPublicKey
                        serviceURL: (NSURL *) aServiceURL;

- (NSString *) base64;

@end
