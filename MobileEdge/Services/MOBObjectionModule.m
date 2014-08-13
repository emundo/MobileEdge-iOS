/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo.
 *
 * Created by Raphael Arias on 8/11/14.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MOBObjectionModule.h"
#import "AMErrorHandler.h"
#import <DDLog.h>
//#import "AMTile.h"
//#import "AMEventCalendarEntry.h"
#import "AMErrorHandlerUI.h"
//#import "AMBackendManager.h"
#import "AMErrorManager.h"
#import "AMADataAccessCoreData.h"
#import "AMADataAccess.h"
//#import "AMDataAccessCoreDataPortfolio.h"

const static int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation MOBObjectionModule

- (void) configure {
    id<AMErrorHandler> errorHandler = [[AMErrorHandlerUI alloc] init];
    [AMErrorManager setSharedErrorHandler:errorHandler];
    [self bind:errorHandler toProtocol:@protocol(AMErrorHandler)];
    
    
    //AMBackendManager *backendManager = [[AMBackendManager alloc] init];
    //[AMBackendManager setSharedManager:backendManager];
    
    
    //Data Access
    [self setupDataAccess];
}


- (void) setupDataAccess;
{
    id<AMErrorHandler> errorHandler = [AMErrorManager sharedErrorHandler];
    
    
    
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AMCoreDataModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    if(!model)
    {
        DDLogError(@"Could not load CoreData model");
    }
    
    
    NSURL *docURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                            inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [docURL URLByAppendingPathComponent:@"Quirin.sqlite"];
    
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc]
                                                 initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:storeURL
                                         options:nil
                                           error:&error])
    {
        DDLogError(@"Could not setup persisent store %@, %@", error, [error userInfo]);
        
        
        [errorHandler handleUnrecoverableErrorWithTitle:NSLocalizedString(@"CoreDataSetupErrorUnrecoverableTitle", @"")
                                                message:NSLocalizedString(@"CoreDataSetupErrorUnrecoverableMessage", @"")];
    }
    
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    
    
    AMADataAccessCoreData *dataAccess = [[AMADataAccessCoreData alloc] init];
    dataAccess.context = context;
    
    
    [self bind:dataAccess toProtocol:@protocol(AMADataAccess)];
    
    
    //AMDataAccessCoreDataPortfolio *dataAccessPortfolio = [[AMDataAccessCoreDataPortfolio alloc] init];
    //dataAccessPortfolio.context = context;
    
    
    //[self bind:dataAccessPortfolio toClass:[AMDataAccessCoreDataPortfolio class]];
}


@end
