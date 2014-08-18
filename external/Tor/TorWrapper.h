//
//  TorWrapper.h
//  wut
//
//  Created by Mike Tigas on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "or/or.h"
//#include "../../dependencies/include/or/or.h"
#include "or/main.h"

@interface TorWrapper : NSThread

-(NSData *)readTorCookie;
@end
