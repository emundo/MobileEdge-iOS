//
//  PTPErrorManager.m
//  pickthatplace
//
//  Created by Alexander Mack on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMErrorManager.h"
#import "AMErrorHandler.h"

static id<AMErrorHandler> errorHandler;

@implementation AMErrorManager

+ (id<AMErrorHandler>) sharedErrorHandler;
{
    return errorHandler;
}

+ (void) setSharedErrorHandler:(id<AMErrorHandler>) aErrorHandler;
{
    errorHandler = aErrorHandler;
}

@end
