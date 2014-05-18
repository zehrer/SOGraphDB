//
//  SOStringStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOTextStore.h"

#import "SOTextIndexStore.h"
#import "SOTextIndexObject.h" 
#import "SOStringData.h"

//@property (nonatomic, strong, readonly) NSURL *indexURL;
//@property (nonatomic, strong, readonly) NSFileHandle *indexfileHandle;
//@property (nonatomic, strong, readonly) NSMutableArray *rageIndex;

@interface SOTextStore ()

@property (nonatomic, strong) SOTextIndexStore *indexStore;

@end

@implementation SOTextStore

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        
        NSURL *indexURL = [url URLByAppendingPathExtension:@"idx"];
        self.indexStore = [[SOTextIndexStore alloc] initWithURL:indexURL];
        
        // TODO: errors of the index??
    }
    
    return self;
}

- (NSURL *)indexStoreURL;
{
    return [self.indexStore url];
}

#pragma mark - CRUD

// TODO add transaction management to indexStore

- (NSNumber *)addString:(NSString *)text;
{
    SOStringData *newStringData  = [[SOStringData alloc] initWithString:text];
    
    SOTextIndexObject *indexObject = [self.indexStore addStringData:newStringData];
    
    if (indexObject) {
        // it seems their is a free spot in the current file
        [self writeStringData:indexObject];
        [self.indexStore updateObject:indexObject];
    } else {
        // no free space
        indexObject = [[SOTextIndexObject alloc] initWithStringData: newStringData];
        [self writeStringDataAtEndOfFile:indexObject];
        [self.indexStore addStringIndex:indexObject];
    }

    return indexObject.id;
}

- (NSString *)readStringAtIndex:(NSNumber *)aIndex;
{
    SOTextIndexObject *indexObject = [self.indexStore readStringIndex:aIndex];
    
    return [self readStringData:indexObject];
}

- (void)updateString:(NSString *)text atIndex:(NSNumber *)aIndex;
{
    SOStringData *newStringData  = [[SOStringData alloc] initWithString:text];
    
    SOTextIndexObject *indexObject = [self.indexStore readStringIndex:aIndex];
    
    if ([self.indexStore updateStringIndex:indexObject withStringData:newStringData]) {
        // seems it found a place in the store
        [self writeStringData:indexObject];
    } else {
        // the seems the string changed to much -> append at the end.
        [self writeStringDataAtEndOfFile:indexObject]; // update pos 
        [self.indexStore updateObject:indexObject];
    }
}

- (void)deleteStringAtIndex:(NSNumber *)aIndex;
{
    [self.indexStore deleteStringIndex:aIndex];
}

#pragma mark - read/write string file

- (NSString *)readStringData:(SOTextIndexObject *)indexObject;
{
    NSData *data = [self read:indexObject.length atPos:indexObject.pos];
    
    return [indexObject decodeString:data];
}

// This methode delete the stringData after it was written
- (void)writeStringData:(SOTextIndexObject *)indexObject;
{
    NSData *data = indexObject.stringData.data;

    [self write:data atPos:indexObject.pos];
    
    indexObject.stringData = nil;
}

// This methode delete the stringData after it was written
- (void)writeStringDataAtEndOfFile:(SOTextIndexObject *)indexObject;
{
    NSData *data = indexObject.stringData.data;
    
    unsigned long long pos = [self writeAtEndOfFile:data];
    
    indexObject.pos = pos;
    indexObject.stringData = nil;
}

@end
