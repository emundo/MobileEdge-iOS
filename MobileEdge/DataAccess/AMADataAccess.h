/*
 * Copyright (c) 2014 eMundo GmbH
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo GmbH. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo GmbH.
 *
 * Created By Alexander Mack on 18.03.14
 */

#import <Foundation/Foundation.h>

@protocol AMADataAccess <NSObject>

#pragma mark -
#pragma mark Saving & Reverting

/**
 * Reverts all unsaved changes.
 */
- (void)revertChanges;

/**
 * Saves all unsaved changes.
 */
- (void)saveChanges;

/**
 * Wipes all saved and unsaved data.
 */
- (void)clearAllData;

/**
 * @discussion Refreshes the given object for any weak references – in case of an underlying core data implementation,
 * the method can be used to refresh properties based on fetch requests (fetched properties).
 */
- (void) refreshObject:(id) aObject;


#pragma mark
#pragma mark Nested Actions & Background Operations

/**
 * Returns a nested data access object with a child context which can be used to perform changes 
 * and merge these changes into the parent context afterwards.
 * @return a nested data access object with a child context
 */
- (id<AMADataAccess>) nestedDataAccess;

/**
 * Performs in background
 * @param perfoming block – the block wich is performed asynchronously in background with the background context.
 */
- (void)performInBackground:(void (^)(id<AMADataAccess> nestedDataAccess))performingBlock;

/**
 * Performs in background on a nested data access context. Does not save changes automatically.
 * @param perfoming block – the block wich is performed asynchronously in background
 * @param the nested data access object with the child context
 */
- (void) performInBackground:(void (^) (void)) performingBlock onNestedDataAccess:(id<AMADataAccess>) nestedDataAccess;

#pragma mark -
#pragma mark Global

/**
 * Insert object for class.
 * Creates a new object of the given class and stores it into the persistent layer.
 * @param class the class to create an object
 */
- (id) insertObjectForClass:(Class) aClass;

/**
 * Find all objects of the specified class.
 * @param class of the objects to search for
 * @return array of all stored objects corresponding to the given class
 */
- (NSArray *) findAll:(Class) aClass;

/**
 * Find all objects of the specified class sorted by a field.
 * @param class of the objects to search for
 * @param name the field or property name for the sort descriptor
 * @param ascending true of asc and false if desc search
 * @return array of all stored objects corresponding to the given class, sorted by the given parameters
 */
- (NSArray *) findAll:(Class) aClass
    sortedByAttribute:(NSString *) aName
            ascending:(BOOL) aAscending;

/**
 * Find object of the specified class with the id matching the field name of the id.
 * @param class of the objects to search for
 * @param search id to search
 * @param field for id comparison
 * @return object corresponding to the given class and id, sorted by the given parameters
 */
- (id) findObject:(Class) aClass
           withId:(id) aSearchId
objectIdFieldName:(NSString *) aFieldName;

/**
 * Find object the objectID matching the given id. Will always return an object in a coredata implementation
 * @param objectID - the id of the object
 * @return object corresponding to the given id, either faulted or not.
 */
- (id) findByObjectID:(id) objectID;

/**
 * Find all objects of the specified class filtered by a predicate and sorted by a field.
 * @param class of the objects to search for
 * @param aPred - the nspredicate to filter
 * @param name the field or property name for the sort descriptor or nil if no order
 * @param ascending true of asc and false if desc search
 * @return array of all stored objects corresponding to the given class, matching and sorted by the given parameters
 */
- (NSArray *) findAll:(Class) aClass
           filteredBy:(NSPredicate *) aPred
    sortedByAttribute:(NSString *) aName
            ascending:(BOOL) aAscending;

- (NSArray *) findAll:(Class) aClass
           filteredBy:(NSPredicate *) aPred
             sortedBy:(NSArray *) aSortDescriptors;

- (void) deleteObject:(id) aObject;

- (void) deleteObjects:(NSArray *) aArrayObjectsToDelete;

@end
