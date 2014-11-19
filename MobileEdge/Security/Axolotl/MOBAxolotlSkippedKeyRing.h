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
 * Created by Raphael Arias on 22/10/14.
 */

#import <Foundation/Foundation.h>

@class NACLSymmetricPrivateKey;

/**
 * A key ring to store a header key and all its associated skipped message keys.
 */
@interface MOBAxolotlSkippedKeyRing : NSObject

/**
 * @discussion The header key
 */
@property (nonatomic, retain, readonly) NACLSymmetricPrivateKey *headerKey;

/**
 * @discussion The array of message keys.
 */
@property (nonatomic, retain, readonly) NSMutableArray *messageKeys;

/**
 * @discussion Initialize the key ring.
 * @param aMessageKeys - the message keys to store
 * @param aHeaderKey - the header key to store
 * @return The initialized key ring
 */
- (instancetype) initWithMessageKeys: (NSMutableArray *) aMessageKeys
                        forHeaderKey: (NACLSymmetricPrivateKey *) aHeaderKey;


@end
