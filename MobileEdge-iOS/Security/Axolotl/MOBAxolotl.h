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
 * Created by Raphael Arias on 8/07/14.
 */

#import <Foundation/Foundation.h>
#import "MOBProtocol.h"

@class MOBRemoteIdentity;

/**
 * The first implementation of a MOBProtocol protocol. Uses Trevor Perrin and 
 * Moxie Marlinspike's Axolotl protocol.
 */
@interface MOBAxolotl : NSObject  <MOBProtocol>


+ (instancetype) cachedProtocolForIdentity: (MOBIdentity *) identity;

#ifdef DEBUG
/**
 * @discussion Testing function to extract shared key material from the session.
 * Used for tests and debugging.
 * @param aRemote - the remote to get session data for.
 * @return the shared key material as data.
 */
- (NSData *) getSessionKeyMaterialForTestingForRemote: (MOBRemoteIdentity *) aRemote;
#endif
@end
