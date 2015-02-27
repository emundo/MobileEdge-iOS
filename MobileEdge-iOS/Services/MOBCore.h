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
 * Created by Raphael Arias on 8/18/14.
 */

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "MOBIdentity.h"
#import "MOBRemoteIdentity.h"
#import "MOBAxolotl.h"
#import "MOBHTTPSessionManager.h"
#import "MOBAnonymizerSettings.h"
#import "MOBAnonymizer.h"
#import "MOBProtocol.h"
#import "MOBTorSettings.h"
#import "MOBError.h"
#import "NSDictionary+Protocol.h"


#ifdef DEBUG
#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF mobileEdgeLogLevel
// Log levels: off, error, warn, info, verbose
static const DDLogLevel mobileEdgeLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel mobileEdgeLogLevel = DDLogLevelWarn;
#endif

/**
 * This is the class that client apps should import. It exports all necessary
 * classes and protocols to manage Identities, Anonymizers and Encryption protocols.
 */
@interface MOBCore : NSObject

/**
 * @discussion The anonymizer.
 */
@property (nonatomic, strong) id <MOBAnonymizer> anonymizer;

/**
 * @discussion Initialize a Core object with anonymizer settings.
 * @param aSettings - the settings for the anonymizer.
 * @return the initialized MOBCore.
 */
- (instancetype) initWithAnonymizerSettings: (id<MOBAnonymizerSettings>) aSettings;

@end
