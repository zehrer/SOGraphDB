//
//  SOStringIndexStoreTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOCoreGraph/SOTextIndexStore.h>

#import "SOTools.h"


@interface SOTextIndexStoreTest : XCTestCase

@end

@implementation SOTextIndexStoreTest

- (NSURL *)testFile;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"stringstore.idx"];
}

- (void)test1StoreFile
{
    NSURL *url = [self testFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOTextIndexStore *store = [[SOTextIndexStore alloc] initWithURL: url];
    
    XCTAssertNotNil(store.fileHandle,@"file is not created");
    XCTAssertNil(store.error, @"error happend?");
    
    [url deleteFile];
    
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
}

@end
