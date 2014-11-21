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
 * Created by Raphael Arias on 8/20/14.
 */

#import <Foundation/Foundation.h>
#import "MOBProtocol.h"

@class MOBRemoteIdentity;

@interface NSDictionary (Protocol)

/**
 * @discussion Decrypt the dictionary, which is assumed to be a parsed JSON
 * message, using a remote identity, the protocol. Will set an error object,
 * when decryption fails.
 * @param aRemoteIdentity - the identity we received the message from.
 * @param aProtocol - the MOBProtocol instance to use for decryption.
 * @param aError - optional error object to set when an error occurrs.
 * @return the decrypted data if decryption succeeds, nil if not.
 */
- (NSData *) decryptedDataFromSender: (MOBRemoteIdentity *) aRemoteIdentity
                        withProtocol: (id <MOBProtocol>) aProtocol
                               error: (NSError **) aError;

@end
