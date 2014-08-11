//
//  AMADataAccessCoreData.m
//  Quirin
//
//  Created by Alexander Mack on 10.07.14.
//
//

#import "AMADataAccessCoreData.h"
#import <DDLog.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AMADataAccessCoreData

#pragma mark -
#pragma mark Save & Discard

- (void)saveChanges;
{
    NSError *error = nil;
    
    @try {
        if(![self.context save:&error])
        {
            //Log
            DDLogError(@"%@", [error localizedDescription]);
            //Notify user
            [self.errorHandler handleUnrecoverableErrorWithTitle:NSLocalizedString(@"DataAccessErrorUnrecoverableTitle", @"")
                                                         message:NSLocalizedString(@"DataAccessErrorUnrecoverableMessage", @"")];
        }
    } @catch(NSException *e) {
        //Log
        DDLogError(@"%@", [e reason]);
        //Notify user
        [self.errorHandler handleUnrecoverableErrorWithTitle:NSLocalizedString(@"DataAccessErrorUnrecoverableTitle", @"")
                                                     message:NSLocalizedString(@"DataAccessErrorUnrecoverableMessage", @"")];
    }
}

- (void)revertChanges;
{
    [self.context rollback];
}

- (void)clearAllData;
{
    //FIXME:Implement
}

- (id<AMADataAccess>)nestedDataAccess;
{
    AMADataAccessCoreData *nestedContext = [[AMADataAccessCoreData alloc] init];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    temporaryContext.parentContext = self.context;
    self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    nestedContext.context = temporaryContext;
    return nestedContext;
}

- (void)performInBackground:(void (^)(id<AMADataAccess> nestedDataAccess))performingBlock;
{
    AMADataAccessCoreData *nestedDataAccess = self.nestedDataAccess;
    __weak AMADataAccessCoreData *weakSelf = self;
    [nestedDataAccess.context performBlockAndWait:^{
        performingBlock(nestedDataAccess);
        NSError *error;
        BOOL savedBackgroundContext = [nestedDataAccess.context save:&error];
        if(savedBackgroundContext && !error) {
            [weakSelf.context save:&error];
        } else {
            DDLogError(@"Error saving private managed context");
        }
        //check for error on main context
        if(error) {
            DDLogError(@"Error performing block in private managed object context");
        }
    }];
}

- (void)performInBackground:(void (^)(void))performingBlock onNestedDataAccess:(id<AMADataAccess>)nestedDataAccess;
{
    [self.context performBlock:performingBlock];
}

- (void) refreshObject:(id) aObject;
{
    [self.context refreshObject:aObject mergeChanges:YES];
}

- (void) childContextDidSave:(NSNotification *) notification;
{
    [self.context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
}

#pragma mark -
#pragma mark Global

- (NSArray *) entitiesWithName:(NSString *) aEntityName
                      matching:(NSPredicate *) aPredicate
                      sortedBy:(NSArray*)aSortDescriptors;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:aEntityName
											  inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:aSortDescriptors];
	[fetchRequest setPredicate:aPredicate];
	
	NSError *error = nil;
	NSArray *entities = [self.context executeFetchRequest:fetchRequest
                                                    error:&error];
	if(nil == entities || error)
	{
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
		return [NSArray array];
	}
	
 	return [NSArray arrayWithArray:entities];
}

- (id) insertObjectForClass:(Class) aClass;
{    
    NSEntityDescription *desc = [NSEntityDescription entityForName:NSStringFromClass(aClass) inManagedObjectContext:self.context];
    id managedObject = [[aClass alloc] initWithEntity:desc insertIntoManagedObjectContext:self.context];
    return managedObject;
}

- (NSArray *) findAll:(Class) aClass;
{
    return [self entitiesWithName:NSStringFromClass(aClass) matching:nil sortedBy:nil];
}

- (NSArray *) findAll:(Class) aClass
    sortedByAttribute:(NSString *) aName
            ascending:(BOOL) aAscending;
{
    NSString *entityName = NSStringFromClass(aClass);
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:aName
                                                                     ascending:aAscending];
    NSArray *arraySortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [self entitiesWithName:entityName matching:nil sortedBy:arraySortDescriptors];
}

- (id) findObject:(Class) aClass
           withId:(NSString *) id
objectIdFieldName:(NSString *) aFieldName;
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", aFieldName, id];
    return [[self entitiesWithName:NSStringFromClass(aClass) matching:pred sortedBy:nil] lastObject];
}

- (id) findByObjectID:(id) objectID;
{
    return [self.context objectWithID:objectID];
}

- (NSArray *) findAll:(Class) aClass
           filteredBy:(NSPredicate *) aPred
    sortedByAttribute:(NSString *) aName
            ascending:(BOOL) aAscending;
{
    NSString *entityName = NSStringFromClass(aClass);
    NSArray *arraySortDescriptors;
    if(aName) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:aName
                                                                         ascending:aAscending];
        arraySortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    } else {
        arraySortDescriptors = nil;
    }
    return [self entitiesWithName:entityName matching:aPred sortedBy:arraySortDescriptors];
}


- (NSArray *) findAll:(Class) aClass
           filteredBy:(NSPredicate *) aPred
             sortedBy:(NSArray *) aSortDescriptors;
{
    NSString *entityName = NSStringFromClass(aClass);
    return [self entitiesWithName:entityName matching:aPred sortedBy:aSortDescriptors];
}


- (void)deleteObject:(id)aObject;
{
    [self.context deleteObject:aObject];
}

- (void)deleteObjects:(NSArray *)aArrayObjectsToDelete;
{
    for(NSManagedObject *current in aArrayObjectsToDelete) {
        [self.context deleteObject:current];
    }
}
@end
