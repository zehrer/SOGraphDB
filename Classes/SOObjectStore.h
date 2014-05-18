//
//  SOObjectStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "SODataStore.h"

@interface SOObjectStore : SODataStore

// this class has to implement SOCoding
@property (nonatomic) Class objectType;

#pragma mark - CRUD ObjectStore

- (id<SOCoding>)createObject;

- (NSNumber *)addObject:(id<SOCoding>)aObj;

- (id<SOCoding>)readObject:(NSNumber *)aID;

- (void)updateObject:(id<SOCoding>)aObj;

- (void)deleteObject:(id<SOCoding>)aObj;

@end
