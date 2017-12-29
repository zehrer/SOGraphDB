//
//  SONodeStoreTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//
#include <stdlib.h>

typedef unsigned int NSUInteger32;

//#define RAND_FROM_TO(min,max) (min + arc4random_uniform(max - min + 1))

#import <XCTest/XCTest.h>

#import <SOGraphDB/SOGraphDB.h>
#import <SOGraphDB/NSURL+SOCore.h>
#import "SONodeStore.h"


#import "NSNumber+SOCoreGraph.h"

#import "SOTools.h"

@interface SONodeStoreTest : XCTestCase <NSCacheDelegate>

@end

const NSUInteger32 NODE_COUNT = 10000;  // one test divide this number by two !!!

@implementation SONodeStoreTest


- (NSURL *)testFile;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"nodestore.db"];
}

- (void)deleteTestFile;
{
    NSURL *url = [self testFile];
    [url deleteFile];
}

- (SONodeStore *)createStore;
{
    //SOCacheFileStore *result = [[SOCacheFileStore alloc] initWithURL:[self testFile]];
    // [result setupStore:[[SONode alloc] init]];
    
    // This is a SOFileStore test !!
    SONodeStore *result = [[SONodeStore alloc] initWithURL:[self testFile]];
    
    return result;
}

- (void)checkNodes:(NSArray *)nodeArray inStore:(SONodeStore *)nodeStore;
{
    for (SONode *oldNode in nodeArray) {
        
        SONode *readNode = (SONode *)[nodeStore readObject:oldNode.id];
        
        XCTAssertEqual(readNode.outRelationshipID, oldNode.outRelationshipID, @"read data not the same");
    }
}

- (NSMutableArray *)createNodes:(SONodeStore *)nodeStore;
{
    NSMutableArray *nodeArray = [NSMutableArray array];
    
    // Create a node graphe
    NSUInteger32 i;
    for (i = 1; i <= NODE_COUNT; i++)
    {
        SONode *node = [[SONode alloc] init];
        
        [node setOutRelationshipID:[NSNumber numberWithID:RAND_FROM_TO(1,200000)]];
        
        [nodeStore addObject:node];
        
        //NSLog(@"Object added: %u", i);
        
        [nodeArray addObject:node];
    }
    
    return nodeArray;
}

- (void)test1DeleteStoreFile
{
    SONodeStore *nodeStore = [self createStore];
    
    XCTAssertNotNil(nodeStore.fileHandle,@"file is not created");
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    [nodeStore.url deleteFile];
    XCTAssertFalse(nodeStore.url.isFileExisting, @"File not deleted?");
}

- (void)test2CreateReadNodes
{
    [self deleteTestFile];
    
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");

    SONode *aNode = [[SONode alloc] init];
    NSData *nodeData = [aNode encodeData];
    
    NSLog(@"Size: %lu", nodeData.length);
    
    NSMutableArray *nodeArray = [self createNodes:nodeStore];
    
    //[nodeStore.cache setDelegate:self];
    //[nodeStore.cache setCountLimit:20000];
    
    NSLog(@"Nodes created %lu",[nodeArray count]);
    
   [self checkNodes:nodeArray inStore:nodeStore];
    
    NSLog(@"Node read !");
    XCTAssertTrue(nodeStore.url.isFileExisting, @"File  deleted?");
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj;
{
    //NSLog(@"Cache willEvictObject: %@", obj);
}

- (void)test3UpdateNodes;
{
    [self deleteTestFile];
    
    SONodeStore *nodeStore = [self createStore];
    [self createNodes:nodeStore];
    
    XCTAssertNil(nodeStore.error, @"error happend?");
    XCTAssertTrue(nodeStore.unusedDataSegments.count == 0, @"no deleted data yet?");
    
    NSMutableArray *nodeArray = [NSMutableArray array];
    NSUInteger32 i;
    
    for (i = 1; i <= NODE_COUNT; i++)
    {
        SONode *node = (SONode *)[nodeStore readObject:[NSNumber numberWithID:i]];
        
        [nodeArray addObject:node];
        [node setOutRelationshipID:[NSNumber numberWithID:RAND_FROM_TO(1,200000)]];
        
        [nodeStore updateObject:node];
    }
    
    [self checkNodes:nodeArray inStore:nodeStore];
    
    XCTAssertTrue(nodeStore.url.isFileExisting, @"File  deleted?");
}

- (void)test4DeleteNodes;
{
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    XCTAssertTrue(nodeStore.unusedDataSegments.count == 0, @"no deleted data yet?");
    
    NSUInteger32 i;
    NSNumber *aID;
    
    NSMutableSet *idSet = [NSMutableSet set];
    
    for (i = 1; i <= NODE_COUNT/2; i++)
    {
        SOID num = RAND_FROM_TO(1,NODE_COUNT);
        aID =  [NSNumber numberWithID:num];
        [nodeStore delete:aID];
        [idSet addObject:aID];
    }
    
    NSUInteger count = idSet.count;
    
    XCTAssertTrue(count == nodeStore.unusedDataSegments.count, @"deleted nodes not similar to data segments?");
    
    NSLog(@"Count of deleted nodes: %lu",count);
    
    for (i = 1; i <= NODE_COUNT; i++)
    {
        aID = [NSNumber numberWithID:i];
        
        SONode *readNode = (SONode *)[nodeStore readObject:aID];
        
        if (!readNode) {
            [idSet removeObject:aID];
        }
    }

    NSUInteger idSetCount = idSet.count;
    NSLog(@"Count : %lu",idSetCount);
    NSLog(@"Count in nodeStore : %lu",nodeStore.unusedDataSegments.count);
    XCTAssertTrue(idSetCount == 0, @"not all deleted nodes found?");
    
    XCTAssertTrue(nodeStore.url.isFileExisting, @"File deleted?");
}

- (void)test5CreateNodes;
{
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    NSMutableArray *nodeArray = [NSMutableArray array];
    
    NSUInteger32 i;
    for (i = 1; i <= NODE_COUNT; i++)
    {
        SONode *node = [[SONode alloc] init];
        
        [node setOutRelationshipID:[NSNumber numberWithID:RAND_FROM_TO(1,200000)]];
        
        [nodeStore addObject:node];
        [nodeArray addObject:node];
    }

    XCTAssertTrue(nodeStore.unusedDataSegments.count == 0, @"not all deleted nodes found?");
    
    XCTAssertTrue(nodeStore.url.isFileExisting, @"File deleted?");
}


- (void)test6RegisterCheck1
{
    NSURL *url = [self testFile];
    [url deleteFile];
    
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    SONode *node = [[SONode alloc] init];
    
    [nodeStore registerObject:node];
    
    XCTAssertTrue([node.id integerValue] == 1, @"Not register?");

}

- (void)test6RegisterCheck2
{
    //NSURL *url = [self testFile];
    
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    SONode *node = (SONode *)[nodeStore readObject:@1];
    
    XCTAssertNil(node, @"Not nil?");

}

- (void)test6RegisterCheck3
{
    NSURL *url = [self testFile];
    [url deleteFile];
    
    SONodeStore *nodeStore = [self createStore];
    XCTAssertNil(nodeStore.error, @"error happend?");
    
    SONode *node1 = [[SONode alloc] init];
    [nodeStore registerObject:node1];
    XCTAssertTrue([node1.id integerValue] == 1, @"Not register?");
    
    SONode *node2 = (SONode *)[nodeStore createObject];
    //[nodeStore registerObject:node2];
    XCTAssertTrue([node2.id integerValue] == 2, @"Not register?");
    
    SONode *node3 = [[SONode alloc] init];
    [nodeStore registerObject:node3];
    XCTAssertTrue([node3.id integerValue] == 3, @"Not register?");
    
    [nodeStore updateObject:node3];
    
    node1 = (SONode *)[nodeStore readObject:@1];
    XCTAssertNil(node1, @"Node Not nil?");
    
    node2 = (SONode *)[nodeStore readObject:@2];
    XCTAssertNotNil(node2, @"Node nil?");
    
    node3 = (SONode *)[nodeStore readObject:@3];
    XCTAssertNotNil(node3, @"Node nil?");
}


@end
