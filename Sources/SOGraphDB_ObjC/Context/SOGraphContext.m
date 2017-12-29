//
//  SOGraphContex.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 18.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SONode.h"

#import "SOCacheDataStore.h"

#import "SOStringDataStore.h"

#import "SOGraphContext.h"

#import "NSNumber+SOCoreGraph.h"

@interface SOGraphContext ()

@property (nonatomic, strong) SOCacheDataStore *nodeStore;
@property (nonatomic, strong) SOCacheDataStore *relationshipStore;
@property (nonatomic, strong) SOCacheDataStore *propertyStore;
@property (nonatomic, strong) SOStringDataStore *stringStore;

@end

static NSString *const cNodeStoreFileName         = @"nodestore.db";
static NSString *const cRelationshipStoreFileName = @"relation.db";
static NSString *const cPropertyStoreFileName     = @"property.db";
static NSString *const cStringStoreFileName       = @"stringstore.db";


@implementation SOGraphContext

- (instancetype)initWithURL:(NSURL *)aURL;
{
    self = [super init];
    if (self) {
        _url = aURL;
        [self setupFileStores];

    }
    return self;
}

- (void)setupFileStores;
{
    NSError *error;
    
    NSFileWrapper *directoryFileWrapper = [[NSFileWrapper alloc] initWithURL:self.url options:NSFileWrapperReadingImmediate error:&error];
    
    if (!directoryFileWrapper) {
        
        // directory don't exist?
        NSFileManager *fileManager = [NSFileManager defaultManager];
        error = nil;  // remove file not found error
        [fileManager createDirectoryAtURL:self.url withIntermediateDirectories:YES attributes:nil error:&error];
        
        // TODO
        _error = error;
    }  else {
         if (![directoryFileWrapper isDirectory]) {
             return;
         }
    }
    
    NSURL * nodeStoreURL = [self.url URLByAppendingPathComponent:cNodeStoreFileName];
    self.nodeStore = [[SOCacheDataStore alloc] initWithURL:nodeStoreURL];
    [self.nodeStore setupStore:[[SONode alloc] init]];
    [self.nodeStore.cache setName:@"nodeStore"];
    
    NSURL * relationshipStoreURL = [self.url URLByAppendingPathComponent:cRelationshipStoreFileName];
    self.relationshipStore = [[SOCacheDataStore alloc] initWithURL:relationshipStoreURL];
    [self.relationshipStore setupStore:[[SORelationship alloc] init]];
    [self.nodeStore.cache setName:@"relationshipStore"];
    
    NSURL * propertyStoreURL = [self.url URLByAppendingPathComponent:cPropertyStoreFileName];
    self.propertyStore = [[SOCacheDataStore alloc] initWithURL:propertyStoreURL];
    [self.propertyStore setupStore:[[SOProperty alloc] init]];
    [self.propertyStore.cache setName:@"propertyStore"];
    
    NSURL * stringStoreURL = [self.url URLByAppendingPathComponent:cStringStoreFileName];
    self.stringStore = [[SOStringDataStore alloc] initWithURL:stringStoreURL];
    
}

- (void)setCacheDelegate:(id<NSCacheDelegate>)cacheDelegate;
{
    self.nodeStore.cache.delegate = cacheDelegate;
    self.relationshipStore.cache.delegate = cacheDelegate;
}

- (void)setCacheLimit:(NSInteger)limit;
{
    [self.nodeStore.cache setCountLimit:limit];
    [self.relationshipStore.cache setCountLimit:limit];
}

#pragma mark - String Store

- (NSNumber *)addString:(NSString *)text;
{
    return [self.stringStore addString:text];
}

- (NSString *)readStringAtIndex:(NSNumber *)aIndex;
{
    return [self.stringStore readStringAtIndex:aIndex];
}

- (void)deleteStringAtIndex:(NSNumber *)aIndex;
{
    [self.stringStore deleteStringAtIndex:aIndex];
}

#pragma mark - CRUD Node

- (SONode *)createNode;
{
    id result = [self.nodeStore createObject];

    [result setContext:self];
    
    return result;
}

- (SONode *)readNode:(NSNumber *)aID;
{
    NSParameterAssert(aID.ID != 0);
    
    id result = [self.nodeStore readObject:aID];
    
    [result setContext:self];  // if result == nil message is ingnored
    
    return result;
}

- (void)updateNode:(SONode *)aObj;
{
    [self.nodeStore updateObject:aObj];
}

- (void)deleteNode:(SONode *)aObj;
{
    [self.nodeStore deleteObject:aObj];  // removed the id
    
    aObj.context = nil;
}

#pragma mark - CRUD Relationship

- (void)registerRelationship:(SORelationship *)aObj;
{
    [self.relationshipStore registerObject:aObj];
    
    [aObj setContext:self];
}

- (void)addRelationship:(SORelationship *)aObj;
{
    [self.relationshipStore addObject:aObj];
    
    [aObj setContext:self];
}

- (SORelationship *)readRelationship:(NSNumber *)aID;
{
    id result =[self.relationshipStore readObject:aID];
    
    if (result) {
        [result setContext:self];
    }
    
    return result;
}

- (void)updateRelationship:(SORelationship *)aObj;
{
    [self.relationshipStore updateObject:aObj];
}

- (void)deleteRelationship:(SORelationship *)aObj;
{
    [self.relationshipStore deleteObject:aObj];  // removed the id
    
    aObj.context = nil;
}

#pragma mark - CRUD Property

- (void)registerProperty:(SOProperty *)aObj;
{
    [self.propertyStore registerObject:aObj];
    
    [aObj setContext:self];
}

- (void)addProperty:(SOProperty *)aObj;
{
    [self.propertyStore addObject:aObj];
    
    [aObj setContext:self];
}

- (SOProperty *)readProperty:(NSNumber *)aID;
{
    id result =[self.propertyStore readObject:aID];
    
    if (result) {
        [result setContext:self];
    }
    
    return result;
}

- (void)updateProperty:(SOProperty *)aObj;
{
    [self.propertyStore updateObject:aObj];
}

- (void)deleteProperty:(SOProperty *)aObj;
{
    [self.propertyStore deleteObject:aObj];  // removed the id
    
    aObj.context = nil;
}

@end
