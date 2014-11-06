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
#import "MOBValueToken.h"
#import "MOBVendorSecret.h"
#import "MOBIdentity.h"

@interface MOBTokenNegotiator : NSObject

// probably not necessary as public interface
- (MOBValueToken *) obtainValueTokenForVendorSecret: (MOBVendorSecret *) aVendorSecret
                                      usingIdentity: (MOBIdentity *) aIdentity;

// takes all unprocessed VendorSecrets from the database and contacts vendors to
// obtain a signature on a blinded ValueToken.
// This should be done by creating a new identity for each vendor (and VendorSecret)
- (void) processPendingVendorSecrets;

@end
