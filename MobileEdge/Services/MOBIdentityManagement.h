//
//  MOBIdentityManagement.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/7/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOBIdentity.h"

@interface MOBIdentityManagement : NSObject

- (MOBIdentity *) createId;

- (MOBIdentity *) createIdWithOptions:(NSString *) options; //TODO change to clearer type

- (MOBIdentity *) refreshId:(MOBIdentity *) aIdentity;

@end
