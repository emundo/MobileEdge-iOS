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
#import "MOBAnonymizerSettings.h"

#define COOKIES_ALLOW_ALL 0
#define COOKIES_BLOCK_THIRDPARTY 1
#define COOKIES_BLOCK_ALL 2

// Sets "Content-Security-Policy" headers. See ProxyURLController.m
#define CONTENTPOLICY_STRICT 0 // Blocks nearly every CSP type
#define CONTENTPOLICY_BLOCK_CONNECT 1 // Blocks `connect-src` (XHR, CORS, WebSocket)
#define CONTENTPOLICY_PERMISSIVE 2 // Allows all content (DANGEROUS: websockets leak outside tor)

#define UA_SPOOF_UNSET 0
#define UA_SPOOF_WIN7_TORBROWSER 1
#define UA_SPOOF_SAFARI_MAC 2
#define UA_SPOOF_IPHONE 3
#define UA_SPOOF_IPAD 4
#define UA_SPOOF_NO 5

#define DNT_HEADER_UNSET 0
#define DNT_HEADER_CANTRACK 1
#define DNT_HEADER_NOTRACK 2

#define X_DEVICE_IS_IPHONE 0
#define X_DEVICE_IS_IPAD 1
#define X_DEVICE_IS_SIM 2


@interface MOBTorSettings : NSObject <MOBAnonymizerSettings>

// list for known domains w/self-signed certs
@property (nonatomic, strong) NSMutableArray *sslWhitelistedDomains;

@property (nonatomic, strong) NSMutableDictionary *settings;

@property (nonatomic, strong) NSString *customUserAgent;

@end
