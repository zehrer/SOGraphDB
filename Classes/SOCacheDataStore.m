//
//  SOCacheFileStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 19.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOCacheDataStore.h"


@implementation SOCacheDataStore

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

// version with cache support
- (NSNumber *)addObject:(id<SOCoding>)aObj;
{
    aObj.id = [self create:[aObj encodeData]];
    
    [self.cache setObject:aObj forKey:aObj.id];
    
    return aObj.id;
}

// version with cache support
- (id)readObject:(NSNumber *)aID;
{
    id<SOCoding> result = [self.cache objectForKey:aID];
    
    if (result == nil) {
        
        result = [super readObject:aID];
        
        if (result) {
            [self.cache setObject:result forKey:aID];
        
        }
    }
    return result;
}

// version with cache support
- (void)deleteObject:(id<SOCoding>)aObj;
{
    [self.cache removeObjectForKey:aObj.id];
    [super deleteObject:aObj];
}

@end
