//
//  SOMutableListArrayTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 21.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOCoreGraph/SOGraphContext.h>

#import <SOCoreGraph/NSURL+SOCore.h>

#import "SOMutableListArray.h"

#import "SOTools.h"
#import "SOTestTools.h"


@interface SOMutableListArrayTest : XCTestCase

@end

@implementation SOMutableListArrayTest

- (NSURL *)testWrapper;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"graphlist.wrapper"];
}

- (void)test1SimpleRelationTest
{
    
    SOMutableListArray *array = [SOMutableListArray array];
    
    XCTAssertNotNil(array, @"object not created?");
}

- (void)test2CountTest
{
    
    SOMutableListArray *array = [SOMutableListArray array];
    
    XCTAssertNotNil(array, @"object not created?");
    
    //[array count];
}


@end
