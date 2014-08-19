/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo.
 *
 * Created by Raphael Arias on 8/18/14.
 */

#import <Foundation/Foundation.h>
#import <DDLog.h>
#import <DDTTYLogger.h>


#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@class MOBTorSettings, TorController;

@interface MOBCore : NSObject

@property (nonatomic, strong) MOBTorSettings *torSettings;
@property (nonatomic, strong) TorController *tor;

@end
