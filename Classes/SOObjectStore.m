//
//  SOObjectStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "SOObjectStore.h"

@implementation SOObjectStore

#pragma mark - CRUD Objects

- (id<SOCoding>)createObject;
{
    id<SOCoding> result = [[self.objectType alloc] init];
    [self addObject:result];
    
    return result;
}

- (NSNumber *)addObject:(id<SOCoding>)aObj;
{
    aObj.id = [self create:[aObj encodeData]];
    
    aObj.isDirty = NO;
    
    return aObj.id;
}

- (id<SOCoding>)readObject:(NSNumber *)aID;
{
    id<SOCoding> result = nil;
    
    NSData *data = [self read:aID];
    
    if (data.length > 0) {
        result = [self.objectType alloc];
        result = [result initWithData:data];
        
        result.id = aID;
    }
    
    return result;
}

- (void)updateObject:(id<SOCoding>)aObj;
{
    if (aObj.isDirty) {
        NSData *data = [aObj encodeData];
        
        [self update:data at:aObj.id];
        
        aObj.isDirty = NO;
    }
}

- (void)deleteObject:(id<SOCoding>)aObj;
{
    [self delete:aObj.id];
    aObj.id = nil;
}

@end
