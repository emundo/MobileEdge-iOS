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
 * Created by Luca Müller on 7/30/14.
 */

#import <Foundation/Foundation.h>
#import "MOBBaseIdentity.h"
#import <SodiumObjc.h>

#define kMOBIdentityKeyPairKey @"identityKeyPair"

@interface MOBIdentity : MOBBaseIdentity

@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *identityKeyPair;
@property (nonatomic, strong) NSString *ttl;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *creationDate;

- (instancetype) init;

- (instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair;

@end
