//
//  AMADataAccessCoreData.h
//  Quirin
//
//  Created by Alexander Mack on 10.07.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AMADataAccess.h"
#import "AMErrorHandler.h"


@interface AMADataAccessCoreData : NSObject <AMADataAccess>

@property (nonatomic,strong) NSManagedObjectContext *context;

@property (nonatomic, weak) id<AMErrorHandler> errorHandler;

@end
