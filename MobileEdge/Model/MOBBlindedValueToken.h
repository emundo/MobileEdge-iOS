//
//  MOBBlindedValueToken.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/7/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOBBlindedValueToken : NSManagedObject

@property (nonatomic, retain) NSString * blindedID;
@property (nonatomic, retain) NSString * blindingFactor;

@end
