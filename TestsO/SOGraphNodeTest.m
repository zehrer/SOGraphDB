//
//  SOGraphNodeTest.m
//  SOGraphDB
//
//  Created by Stephan Zehrer on 27.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOGraphDB/SOGraphDB.h>
#import <SOGraphDB/NSURL+SOCore.h>

#import "SOTools.h"
#import "SOTestTools.h"

@interface SOGraphNodeTest : XCTestCase

@end

@implementation SOGraphNodeTest

- (NSURL *)testWrapper;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"graphdata.wrapper"];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj;
{
    NSLog(@"Cache %@ willEvictObject: %@",cache.name, [obj id]);
}

// DONE -> covered in other relationship unit tests
- (void)test1OutRelationshipTo
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *data1 = [context createNode];  //@2
    SONode *data2 = [context createNode];  //@3
    
    SORelationship *rel = [data1 addRelatedNode:data2]; //@1
    XCTAssertNotNil(rel, @"No Relationship?");
    
    SORelationship *rel2 = [data1 outRelationshipTo:data2];
    XCTAssertTrue([rel isEqual:rel2], @"Not same relationship?");
}

// DONE -> covered in testRelationshipList
- (void)test1DeleteRelatedNode
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *listNode = [context createNode];  //@2
    
    SONode *data1 = [context createNode];  //@3
    SONode *data2 = [context createNode];  //@3
    SONode *data3 = [context createNode];  //@3
    
    SORelationship *rel1 = [listNode addRelatedNode:data1]; //@1
    [listNode addRelatedNode:data2]; //@2
    SORelationship *rel2 = [listNode addRelatedNode:data3]; //@3
    
    NSArray *outArray = [listNode outRelationshipArray];
    XCTAssertTrue([outArray count] == 3,@"");
    
    //NSArray *inArray = [data2 inRelationshipArray];
    //XCTAssertTrue([inArray count] == 1,@"");
    
    [listNode deleteRelatedNode:data2];
    
    XCTAssertTrue([outArray count] == 2,@"");
    //XCTAssertTrue([inArray count] == 0,@"");
    
    SORelationship *rel = [context readRelationship:@2];
    XCTAssertNil(rel, @"Not Deleted");
    
    rel = [listNode outRelationshipTo:data1];
    XCTAssertEqual(rel1, rel, @"Is not the same?");
    
    rel = [listNode outRelationshipTo:data3];
    XCTAssertEqual(rel2, rel, @"Is not the same?");
}

// TODO: enumarator not implemented yet
- (void)test1RelatedNodeEnumerator
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *listNode = [context createNode];  //@1
    
    [listNode addRelatedNode:[context createNode]];
    [listNode addRelatedNode:[context createNode]];
    [listNode addRelatedNode:[context createNode]];

    for (SONode *aNode in listNode.relatedNodeEnumerator) {
        NSLog(@"%@",aNode.id);
    }
}


@end
