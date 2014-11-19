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
 * Created by Raphael Arias on 16/10/14.
 */

#import <Foundation/Foundation.h>

@class NACLSymmetricPrivateKey;

/**
 * Representation of an Axolotl chain key including some utility methods to handle it.
 */
@interface MOBAxolotlChainKey : NSObject <NSCoding>

/**
 * @discussion The data of the chain key.
 */
@property (nonatomic, retain, readonly) NSData *data;

/**
 * @discussion Initialize a chain key with chain key data.
 * @param aInputData - the data to initialize the key with
 * @return the initialized chain key
 */
- (instancetype) initWithKeyData: (NSData *) aInputData;

/**
 * @discussion Generate and returnt the next message key. This also advances the chain key!
 * @return the next message key
 */
- (NACLSymmetricPrivateKey *) nextMessageKey;

@end
