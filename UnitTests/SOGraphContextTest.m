//
//  SOGraphContextTest.m
//  SOGraphDB
//
//  Created by Stephan Zehrer on 18.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOGraphDB/SOGraphDB.h>
#import <SOGraphDB/NSURL+SOCore.h>

#import "SOTools.h"
#import "SOTestTools.h"

static NSString *const testStringUTF8 = @"01234567890123456789";
static NSString *const testStringUTF8U1 = @"98765432109876543210";           //20   // use case 1 update: same size
static NSString *const testStringUTF8U2 = @"987654321098";                   //12   // use case 2 update: smaller size
static NSString *const testStringUTF8U3 = @"987654321098765432109876543210"; //30    // use case 3 update: larger size
static NSString *const testStringUTF16 = @"\u6523\u6523\u6523\u6523";        //10   // should be better in UTF16 as in UTF8

@interface SOGraphContextTest : XCTestCase <NSCacheDelegate>

@end

@implementation SOGraphContextTest

- (NSURL *)testWrapper;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"graphdata.wrapper"];
}

- (void)test1InitDeleteContextWrapper
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    [url deleteFile];
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
}

- (void)test1ReadNode
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *testNode = [context readNode:@20];
    
    XCTAssertNil(testNode, @"why is not nil?");
}

- (void)test2SimpleNodeSetup
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *nameType = [context createNode]; // @1
    
    SONode *data1 = [context createNode];  //@2
    [data1 setStringValue:testStringUTF8U2 forKey:nameType];
    
    SONode *data2 = [context createNode];  //@3
    [data2 setStringValue:testStringUTF16 forKey:nameType];
    
    NSLog(@"text: %@", [data1 stringValueForKey:nameType]);
    
    
    // NEW INSTANCE OF THE STORE
    context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    nameType = [context readNode:@1];
    
    XCTAssertNotNil(nameType, @"Seems data missing?");
    
    data1 = [context readNode:@2];
    
    XCTAssertNotNil(data1, @"Seems data missing?");
    
    NSString *text = [data1 stringValueForKey:nameType];
    
    XCTAssertTrue([testStringUTF8U2 isEqualToString:text], @"Text not similar");
}


- (void)test2UTF16String
{
    NSURL *url = [self testWrapper];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    XCTAssertNotNil(context, @"context not created?");
    XCTAssertNil(context.error, @"error happend?");
    
    SONode *nameType = [context readNode:@1];
    
    XCTAssertNotNil(nameType, @"Seems data missing?");
    
     SONode *data2 = [context readNode:@3];
    
    XCTAssertNotNil(data2, @"Seems data missing?");
    
    NSString *text = [data2 stringValueForKey:nameType];
    
    XCTAssertTrue([testStringUTF16 isEqualToString:text], @"Text not similar");
}

- (void)test3CreateBigGraph
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    // the test tool use this node (if it exist) to set the id as an long value property
    [context createNode]; // @1
    
    SOTestTools *tool = [[SOTestTools alloc] initWithContext:context];
    
    [context setCacheLimit:5000];
    
    SONode *rootNode = [tool createNodeGraphWithDepth:10];  //8 = 511 nodes ; 10 = 2047 nodes ; 15 = 65535 nodes
    
    NSInteger count = [SOTestTools traverseGraphFromNode2:rootNode];
    
    XCTAssertTrue(tool.createdNodes == count, @"Node numer is not the same");
    XCTAssertTrue(url.isFileExisting, @"File deleted?");
    
}

- (void)test4CreateBigGraph
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    SOTestTools *tool = [[SOTestTools alloc] initWithContext:context];
    
    //[context setCacheDelegate:self];
    //[context setCacheLimit:200000];
    
    //8 = 511 nodes ; 9 = 1023;  10 = 2047 nodes ; 15 = 65535 nodes ; 18 = 524287
    SONode *rootNode = [tool createNodeGraphWithDepth:10];

    
    [tool traverseGraphFromNode6:rootNode];
    
    XCTAssertTrue(tool.createdNodes == tool.recursiveNodeCount, @"Node number is not the same");
    XCTAssertTrue(url.isFileExisting, @"File deleted?");
    
    [context setCacheDelegate:nil];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj;
{
    NSLog(@"Cache %@ willEvictObject: %@",cache.name, [obj id]);
}

- (void)test5DeleteProperty1
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    SONode *nameType = [context createNode]; // @1
    
    SONode *data1 = [context createNode];  //@2
    [data1 setStringValue:testStringUTF8U2 forKey:nameType];

    NSString *text = [data1 stringValueForKey:nameType];
    XCTAssertTrue([testStringUTF8U2 isEqualToString:text], @"Text not similar");
    
    [data1 deleteValueforKey:nameType];
    
    text = [data1 stringValueForKey:nameType];
    XCTAssertNil(text, @"Text not deleted?");
}


- (void)test5DeleteProperty2
{
    NSURL *url = [self testWrapper];
    [url deleteFile];
    
    SOGraphContext *context = [[SOGraphContext alloc] initWithURL:url];
    
    SONode *nameType1 = [context createNode]; // @1
    SONode *nameType2 = [context createNode]; // @2
    SONode *nameType3 = [context createNode]; // @2
    
    SONode *data1 = [context createNode];  //@3
    [data1 setStringValue:testStringUTF8U2 forKey:nameType1];
    [data1 setStringValue:testStringUTF8U2 forKey:nameType2];
    [data1 setStringValue:testStringUTF8U2 forKey:nameType3];
    
    NSString *text = [data1 stringValueForKey:nameType1];
    XCTAssertTrue([testStringUTF8U2 isEqualToString:text], @"Text not similar");
    
    text = [data1 stringValueForKey:nameType2];
    XCTAssertTrue([testStringUTF8U2 isEqualToString:text], @"Text not similar");
    
    text = [data1 stringValueForKey:nameType3];
    XCTAssertTrue([testStringUTF8U2 isEqualToString:text], @"Text not similar");
    
    [data1 deleteValueforKey:nameType2];
    
    text = [data1 stringValueForKey:nameType2];
    XCTAssertNil(text, @"Text not deleted?");
}


- (void)test6SimpleRelationshipDelete
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
    
    NSArray *outArray = [data1 outRelationshipArray];
    XCTAssertTrue([outArray count] == 1,@"");
    
    NSArray *inArray = [data2 inRelationshipArray];
    XCTAssertTrue([inArray count] == 1,@"");
    
    [rel delete];
    
    XCTAssertTrue([outArray count] == 0,@"");
    XCTAssertTrue([inArray count] == 0,@"");
    
    rel = [context readRelationship:@1];
    XCTAssertNil(rel, @"Not Deleted");
}


- (void)test7RelationshipList
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
    
    //SORelationship *rel1 =
    [listNode addRelatedNode:data1]; //@1
    SORelationship *rel2 = [listNode addRelatedNode:data2]; //@2
    //SORelationship *rel3 =
    [listNode addRelatedNode:data3]; //@3
    //XCTAssertNotNil(rel1, @"No Relationship?");
    
    NSArray *outArray = [listNode outRelationshipArray];
    XCTAssertTrue([outArray count] == 3,@"");
    
    //NSArray *inArray = [data2 inRelationshipArray];
    //XCTAssertTrue([inArray count] == 1,@"");
    
    [rel2 delete];
    
    XCTAssertTrue([outArray count] == 2,@"");
    //XCTAssertTrue([inArray count] == 0,@"");
    
    SORelationship *rel = [context readRelationship:@2];
    XCTAssertNil(rel, @"Not Deleted");
}


/**
 SONode *testNode = [context readNode:[NSNumber numberWithID:2]];
 NSArray *ouLinks = [testNode relatedNodes];
 
 XCTAssertTrue([ouLinks count] == 2,@"what happends with related nodes?");
 */

@end
