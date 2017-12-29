//
//  SOFileStoreTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

@import XCTest;
@import SOGraphDB;

@interface SOFileStoreTest : XCTestCase

@end

@implementation SOFileStoreTest

- (NSURL *)testFile;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"data.db"];
}

- (void)test0Delete
{
    NSURL *url = [self testFile];
    
    [url deleteFile];
    
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
}

- (void)test1StoreFile
{
    NSURL *url = [self testFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOManagedDataStore *fileStore = [[SOManagedDataStore alloc] initWithURL: url];
    
    XCTAssertNotNil(fileStore.fileHandle,@"file is not created");
    XCTAssertNil(fileStore.error, @"error happend?");
    
    [url deleteFile];
    
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
}

- (void)test2CreateStoreFile
{
    NSURL *url = [self testFile];
    
    SOManagedDataStore *fileStore = [[SOManagedDataStore alloc] initWithURL:url];

    XCTAssertNotNil(fileStore.fileHandle,@"file is not created");
    XCTAssertNil(fileStore.error, @"error happend?");
    XCTAssertTrue(url.isFileExisting, @"File deleted?");
}

- (void)test3WriteData1
{
    NSURL *url = [self testFile];
    
    SOManagedDataStore *fileStore = [[SOManagedDataStore alloc] initWithURL:url];
    
    XCTAssertNotNil(fileStore.fileHandle,@"file is not created");
    XCTAssertNil(fileStore.error, @"error happend?");
    
    NSUInteger dataValue = 42;
    NSData *data = [[NSData alloc] initWithBytes:&dataValue length:sizeof(dataValue)];
    
    unsigned long long pos = [fileStore endOfFile];
    
    [fileStore write:data atPos:pos];
    
}

- (void)test3WriteData2
{
    NSURL *url = [self testFile];
    
    SOManagedDataStore *fileStore = [[SOManagedDataStore alloc] initWithURL:url];
    
    XCTAssertNotNil(fileStore.fileHandle,@"file is not created");
    XCTAssertNil(fileStore.error, @"error happend?");
    
    NSUInteger dataValue = 42;
    NSData *data = [[NSData alloc] initWithBytes:&dataValue length:sizeof(dataValue)];
    
    unsigned long long pos = [fileStore endOfFile] +1;
    
    [fileStore write:data atPos:pos];
    
}

@end
