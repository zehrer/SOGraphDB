//
//  SOCacheFileStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 19.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOManagedDataStore.h"

/** 
 * This class override some methode to add a cache 
 */
@interface SOCacheDataStore : SOManagedDataStore

@property (nonatomic, strong, readonly) NSCache *cache;

/**
 - (NSNumber *)addObject:(id<SOCoding>)aObj;
 - (id)readObject:(NSNumber *)aID;
 - (void)deleteObject:(id<SOCoding>)aObj;
 */

@end
