//
//  SOStringStoreTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 21.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOGraphDB/SOStringDataStore.h>
#import <SOGraphDB/SOCSVReader.h>

#import "NSURL+SOCore.h"

#import "SOTools.h"

#import "testdata.h"

@interface SOStringStoreTest : XCTestCase <SOCVSReadHandler>

@property SOStringDataStore *tempStore;

@end


@implementation SOStringStoreTest

// [url deleteFile];

- (NSURL *)testFile;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"stringstore.db"];
}

- (void)test1InitStoreFile
{
    NSURL *url = [self testFile];
    
    SOStringDataStore *store = [[SOStringDataStore alloc] initWithURL: url];
    
    XCTAssertNotNil(store.fileHandle,@"file is not created");
    XCTAssertNil(store.error, @"error happend?");
    
    [url deleteFile];
    
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
}

- (void)test2AddReadString
{
    NSURL *url = [self testFile];

    [url deleteFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOStringDataStore *store = [[SOStringDataStore alloc] initWithURL: url];
    
    XCTAssertNil(store.error, @"error happend?");
    
    NSNumber *index1 = [store addString:testStringUTF8];
    NSNumber *index2 = [store addString:testStringUTF16];
    
    XCTAssertNotNil(index1, @"no index???");
    XCTAssertNotNil(index2, @"no index???");
    
    NSString *result1 = [store readStringAtIndex:index1];
    XCTAssertTrue([testStringUTF8 isEqualToString:result1],@"Is not the same?" );

    NSString *result2 = [store readStringAtIndex:index2];
    XCTAssertTrue([testStringUTF16 isEqualToString:result2],@"Is not the same?" );
    
}

// If the file is not new, add already existing strings and compare them
- (void)test3AddReadString;
{
    
    NSURL *url = [self testFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOStringDataStore *store = [[SOStringDataStore alloc] initWithURL: url];
    
    XCTAssertNil(store.error, @"error happend?");
    
    NSNumber *index1 = [store addString:testStringUTF8];
    NSNumber *index2 = [store addString:testStringUTF16];
    
    XCTAssertNotNil(index1, @"no index???");
    XCTAssertNotNil(index2, @"no index???");
    
    NSString *result1 = [store readStringAtIndex:index1];
    XCTAssertTrue([testStringUTF8 isEqualToString:result1],@"Is not the same?" );
    
    NSString *result2 = [store readStringAtIndex:index2];
    XCTAssertTrue([testStringUTF16 isEqualToString:result2],@"Is not the same?" );
    
}

- (void)test4Delete
{
    NSURL *url = [self testFile];
    
    SOStringDataStore *store = [[SOStringDataStore alloc] initWithURL: url];
    
    NSNumber *index = [NSNumber numberWithUnsignedLong:1];
    
    [store deleteStringAtIndex:index];
    
    NSString *result = [store readStringAtIndex:index];
    
    XCTAssertNil(result, @"Is not the same?");
}

- (void)test5CSVData
{
    NSURL *url = [self testFile];
    
    [url deleteFile];
    
    SOStringDataStore *store = [[SOStringDataStore alloc] initWithURL: url];
    NSLog(@"URL: %@", [url path]);
    self.tempStore = store;
    
    // CSV Reader
    NSURL *dataURL = [NSURL fileURLWithPath:@"/Users/steve/Downloads/Names/genderizer/name_gender.csv"];
    SOCSVReader *csvReader = [[SOCSVReader alloc] initWithURL:dataURL];
    csvReader.delegate = self;
    [csvReader readCSVFile];
    
    //NSUInteger index = [store ]
    
    //NSString *result = [store readStringAtIndex:index];
    
    //XCTAssertNil(result, @"Is not the same?");
}

- (void)readLine:(NSArray *)items; {
    
    [self.tempStore addString:items[0]];
    //NSLog(@"%@",items[0]);
    
}





@end
