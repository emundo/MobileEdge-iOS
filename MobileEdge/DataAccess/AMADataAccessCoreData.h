//
//  AMADataAccessCoreData.h
//  Quirin
//
//  Created by Alexander Mack on 10.07.14.
//
//

#import <Foundation/Foundation.h>
#import "AMADataAccess.h"
#import "QBErrorHandling.h"


@interface AMADataAccessCoreData : NSObject <AMADataAccess>

@property (nonatomic,strong) NSManagedObjectContext *context;

@property (nonatomic, weak) id<QBErrorHandling> errorHandler;

@end
