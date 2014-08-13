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
