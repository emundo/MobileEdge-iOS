//
//  MOBValueToken.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/7/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOBValueToken : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * signature;

@end
