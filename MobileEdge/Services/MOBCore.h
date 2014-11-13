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
#import <DDLog.h>
#import <DDTTYLogger.h>
#import "MOBIdentity.h"
#import "MOBRemoteIdentity.h"
#import "MOBAxolotl.h"
#import "MOBHTTPRequestOperationManager.h"
#import "MOBAnonymizerSettings.h"
#import "MOBAnonymizer.h"
#import "MOBTorSettings.h"
#import "MOBError.h"


#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@class TorController;

@interface MOBCore : NSObject

@property (nonatomic, strong) id <MOBAnonymizer> anonymizer;

- (instancetype) initWithAnonymizerSettings: (id<MOBAnonymizerSettings>) aSettings;

@end
