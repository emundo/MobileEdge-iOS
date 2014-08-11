//
//  MOBVendorSecret.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/11/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOBVendorSecret : NSManagedObject

@property (nonatomic, retain) NSData * data;

@end
