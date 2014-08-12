//
//  MOBTokenNegotiator.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/7/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

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
