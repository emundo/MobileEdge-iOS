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
 * Created by Raphael Arias on 8/11/14.
 */

#import <Foundation/Foundation.h>
#import "MOBAnonymizer.h"

/**
 * The first implementation of a MOBAnonymizer using Tor to anonymize connections.
 */
@interface MOBTorInterface : NSObject <MOBAnonymizer, NSURLSessionDataDelegate>

/**
 * @discussion The settings object. Must implement the MOBAnonymizerSettings protocol.
 */
@property (nonatomic, retain) id <MOBAnonymizerSettings> settings;

@end
