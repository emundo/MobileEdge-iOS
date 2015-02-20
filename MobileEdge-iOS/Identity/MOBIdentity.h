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
#define kMOBIdentityCreationDateKey @"creationDate"
#define kMOBIdentityTTLKey @"ttl"
#define kMOBIdentityCommentKey @"comment"

/**
 * @discussion A Class to represent a local Identity. Inherits from MOBBaseIdentity,
 * So it has an extra public key field, additionally to the identityKeyPair defined
 * here.
 */
@interface MOBIdentity : MOBBaseIdentity

/**
 * @discussion The identity public and private key pair.
 */
@property (nonatomic, strong, readonly) NACLAsymmetricKeyPair *identityKeyPair;

/**
 * @discussion A optional time to live for the identity.
 * This is not yet implemented, but using an identity with elapsed ttl
 * should fail and force application programmers to either create new identity
 * or refresh this one.
 */
@property (nonatomic, strong) NSDate *ttl;

/**
 * @discussion Date of the identity creation. This could be useful for users to
 * associate identities with some context.
 */
@property (nonatomic, strong, readonly) NSDate *creationDate;

/**
 * @discussion A comment the application can add to the identity to make it more
 * identifiable.
 */
@property (nonatomic, strong) NSString *comment;

/**
 * @discussion Initialize a new Identity object. A public/private key pair is
 * created.
 * @return the initialized Identity object.
 */
- (instancetype) init;

/**
 * @discussion Initialize a new Identity object with a given public/private key pair.
 * @return the initialized Identity object.
 */
- (instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair;


- (NSString *) base64;

@end
