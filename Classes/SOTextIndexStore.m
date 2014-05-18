//
//  SOStringIndexStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOTextIndexStore.h"

#import "SOStringData.h"

#import "NSNumber+SOCoreGraph.h"

@interface SOTextIndexStore ()

//
@property (nonatomic, strong) NSMutableArray *rangeIndex;
@property (nonatomic, strong) NSMutableSet *unusedIndexObjects;

@end

@implementation SOTextIndexStore

#pragma mark - SOFileStore

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        
        self.objectType = [SOTextIndexObject class];
        
        self.fileOffset = 1;
        self.dataSize = [SOTextIndexObject dataSize];
        
        self.rangeIndex = [NSMutableArray array];
        self.unusedIndexObjects = [NSMutableSet set];
        
        [self readIndexFile];
    }
    
    return self;
}

#pragma mark - SODataStore

- (NSData *)readHeader;
{
    return nil;
}

#pragma mark - SOStringIndeStore

- (void)readIndexFile;
{
    unsigned long long end = [self.fileHandle seekToEndOfFile];
    
    unsigned long long pos = self.fileOffset;
    
    [self.fileHandle seekToFileOffset:pos];
    
    SOTextIndexObject *indexObject = nil;
    
    long ID = 0;
    
    while (pos < end) {
        
        indexObject = [[SOTextIndexObject alloc] initWithID:ID];
        
        [indexObject decodeData:self.fileHandle];
        
        // add to main index
        [self.rangeIndex addObject:indexObject];
        
        if (![indexObject isUsed]) {
          // is not used add additionally to unused index
          [self.unusedIndexObjects addObject:indexObject];
        }
        
        pos = self.fileHandle.offsetInFile;
        ID++;
    }
}

#pragma mark Interface


- (SOTextIndexObject *)addStringData:(SOStringData *)aStringData;
{
    unsigned long stringLength = aStringData.length;
    
    SOTextIndexObject *indexObject = [self findUnusedIndexObject:stringLength];
    
    if (indexObject) {
        
        if (indexObject.length > stringLength) {
            
            [self reduceIndexObject:indexObject toNewLenght:stringLength];
            
        }
        
        indexObject.stringData = aStringData; // change the length of the indexObject
        
        [self endableIndexObject:indexObject];
        
        return indexObject;
    }
    
    return nil;
}

// Used for both
// - internal created new objects (e.g. a new object managing a range of a updated string)
// - external created objects (e.g. ???)
- (SOTextIndexObject *)addStringIndex:(SOTextIndexObject *)indexObject;
{
    if (indexObject.id == nil) {
        
        NSNumber *aID = [self addObject:indexObject];
        
        [self.rangeIndex insertObject:indexObject atIndex:[aID unsignedLongValue]];
        
        if (!indexObject.isUsed) {
            [self.unusedIndexObjects addObject:indexObject];
        }
        
        return indexObject;
    }
    
    return nil;
}

- (SOTextIndexObject *)readStringIndex:(NSNumber *)aID;
{
    SOTextIndexObject *indexObject =  [self.rangeIndex objectAtIndex:[aID unsignedLongValue]];
    
    if (indexObject.isUsed) {
        return indexObject;
    }
    
    return nil;
}

- (BOOL)updateStringIndex:(SOTextIndexObject *)indexObject withStringData:(SOStringData *)newStringData;
{
    NSUInteger newLength = newStringData.length;
    
    // handle only content change
    if (newLength == indexObject.length) {
        // seems the size of the string did not change -> just write it again
        
        indexObject.stringData = newStringData;
        
        return YES;
    }
    
    if (newLength < indexObject.length ) {
        // the order is important
        
        // 1. reduce the indexObject
        [self reduceIndexObject:indexObject toStringData:newStringData];
        
        return YES;
    }
    
    if (newLength > indexObject.length) {
        // find free spot
        // TODO
        
        // manage free space in the string store file by a new index object.
        SOTextIndexObject *newIndexObject = [[SOTextIndexObject alloc] initWithIndexObject:indexObject];

        [self addStringIndex:newIndexObject];
        
        indexObject.stringData = newStringData;
        
    }
    
    // seems the new string is to long for the store
    return NO;
}

- (void)deleteStringIndex:(NSNumber *)aID;
{
    SOTextIndexObject *indexObject =  [self readStringIndex:aID];
    
    if (indexObject) {
            [self disableIndexObject:indexObject];
    }
}

#pragma mark - SOIndexObject

- (SOTextIndexObject *)findUnusedIndexObject:(unsigned long)length
{
    // Improve search :)
    for (SOTextIndexObject *indexObject in self.unusedIndexObjects) {
        if (indexObject.length >= length) {
            return indexObject;
        }
    }
    
    return nil;
}


- (void)reduceIndexObject:(SOTextIndexObject *)indexObject toStringData:(SOStringData *)newStringData;
{
    unsigned long oldLenght = indexObject.length;
    unsigned long newLength = newStringData.length;
    
    NSParameterAssert(newLength < oldLenght);
    
    // create a new index object for the new free space
    SOTextIndexObject *newIndexObject = [[SOTextIndexObject alloc] init];
    
    newIndexObject.pos = indexObject.pos + newLength;
    newIndexObject.length = oldLenght - newLength;
    newIndexObject.used = NO; // mark as free space
    
    [self addStringIndex:newIndexObject];
    
    indexObject.stringData = newStringData;
    
    [self updateObject:indexObject];
}


// TODO check if this can be replaced by the other methode
- (void)reduceIndexObject:(SOTextIndexObject *)indexObject toNewLenght:(unsigned long)newLength;
{
    unsigned long oldLenght = indexObject.length;
    
    NSParameterAssert(newLength < oldLenght);
    
    // create a new index object for the new free space
    SOTextIndexObject *newIndexObject = [[SOTextIndexObject alloc] init];
    
    newIndexObject.pos = indexObject.pos + newLength;
    newIndexObject.length = oldLenght - newLength;
    newIndexObject.used = NO; // mark as free space
    
    [self addStringIndex:newIndexObject];
}

- (void)disableIndexObject:(SOTextIndexObject *)indexObject;
{
    indexObject.used = NO;
    [self.unusedIndexObjects addObject:indexObject];
    
    [self updateObject:indexObject];
}

- (void)endableIndexObject:(SOTextIndexObject *)indexObject;
{
    [indexObject setUsed:YES];
    [self.unusedIndexObjects removeObject:indexObject];
    
    [self updateObject:indexObject];
}

@end
