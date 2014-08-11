//
//  PTPErrorManager.h
//  pickthatplace
//
//  Created by Alexander Mack on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMErrorHandler.h"

@interface AMErrorManager : NSObject

+ (id<AMErrorHandler>) sharedErrorHandler;
+ (void) setSharedErrorHandler:(id<AMErrorHandler>) aErrorHandler;

@end
