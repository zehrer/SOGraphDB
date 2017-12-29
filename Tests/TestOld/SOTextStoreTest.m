//
//  SOStringStoreTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 25.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SOCoreGraph/SOTextStore.h>

#import "SOTools.h"

#import "testdata.h"

@interface SOTextStoreTest : XCTestCase

@end

@implementation SOTextStoreTest

- (void)test1InitStoreFile
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    XCTAssertNotNil(store.fileHandle,@"file is not created");
    XCTAssertNil(store.error, @"error happend?");
    
    [self deleteStoreFiles:store];
    
    XCTAssertFalse(url.isFileExisting, @"File not deleted?");
    XCTAssertFalse(store.indexStoreURL.isFileExisting, @"File not deleted?");
}


- (void)test2AddReadString
{
    NSURL *url = [self testFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    XCTAssertNil(store.error, @"error happend?");
    
    NSNumber *index = [store addString:testStringUTF8];
    
    XCTAssertNotNil(index, @"no index???");
    
    NSString *result = [store readStringAtIndex:index];
    
    XCTAssertTrue([testStringUTF8 isEqualToString:result],@"Is not the same?" );
    
}

- (void)test2ReadString2
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    NSString *result = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    XCTAssertTrue([testStringUTF8 isEqualToString:result],@"Is not the same?" );
}

- (void)test3UpdateString1
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    [store updateString:testStringUTF8U1 atIndex:[NSNumber numberWithUnsignedLong:0]];
    
    NSString *result = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    XCTAssertTrue([testStringUTF8U1 isEqualToString:result],@"Is not the same?" );
}

- (void)test3UpdateString2
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    [store updateString:testStringUTF8U2 atIndex:[NSNumber numberWithUnsignedLong:0]];
    
    NSString *result = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    XCTAssertTrue([testStringUTF8U2 isEqualToString:result],@"Is not the same?" );
}

- (void)test3UpdateString3
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    [store updateString:testStringUTF8U3 atIndex:[NSNumber numberWithUnsignedLong:0]];
    
    NSString *result = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    XCTAssertTrue([testStringUTF8U3 isEqualToString:result],@"Is not the same?" );
}

- (void)test4Delete
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    [store deleteStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    NSString *result = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:0]];
    
    XCTAssertNil(result, @"Is not the same?");
}

- (void)test5AddAfterDelete
{
    NSURL *url = [self testFile];
    
    NSLog(@"URL: %@", [url path]);
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    XCTAssertNil(store.error, @"error happend?");
    
    NSNumber *index = [store addString:testStringUTF16];
    
    XCTAssertNotNil(index, @"no index???");
    
    NSString *result = [store readStringAtIndex:index];
    
    XCTAssertTrue([result isEqualToString:testStringUTF16],@"Is not the same?" );
    
}

- (void)test6RegressionTest1
{
    NSURL *url = [self testFile];
    
    SOTextStore *store = [[SOTextStore alloc] initWithURL: url];
    
    //NSString * string = [store readStringAtIndex:[NSNumber numberWithUnsignedLong:2]];
    
    //NSMutableDictionary *stringDict = [self readTextFile2:@"testdata_001.txt" inStore:store];
    NSMutableDictionary *stringDict = [self generateTestData:store];
    
    [self testStore:store with:stringDict];
}

/**
- (void)test6RegressionTest2
{
    NSURL *url = [self testFile];
    
    SOStringStore *store = [[SOStringStore alloc] initWithURL: url];
    
    NSMutableDictionary *stringDict = [self generateTestData:store];

    //[self testStore:store with:stringDict];
}
*/

- (NSURL *)testFile;
{
    return [[SOTools tempDirectory] URLByAppendingPathComponent:@"stringstore.db"];
}

- (void)deleteStoreFiles:(SOTextStore *)store;
{
    [[store url] deleteFile];
    [[store indexStoreURL] deleteFile];
}

const NSUInteger COUNT = 10000;

- (NSMutableDictionary *)generateTestData:(SOTextStore *)store;
{
    
    NSMutableDictionary *stringDict = [NSMutableDictionary dictionary];
    
    NSMutableString  *text = [NSMutableString string];
    NSUInteger i = 0;
    NSString *text1 = nil;
    NSString *text2 = nil;
    NSNumber *index = nil;
    
    for (i = 1; i <= COUNT; i++)
    {
        //     8      4    4    4    12
        //"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        text1 = [[NSUUID UUID] UUIDString];
        text2 = [text1 substringToIndex:RAND_FROM_TO(9,36)];
        
        
        [text appendString:text2];
        [text appendString:@"\r"];
        
        index = [store addString:text2];
        [stringDict setObject:text2 forKey:index];
        
        text1 = [store readStringAtIndex:index];
        
        if (![text1 isEqualToString:text2]) {
            NSLog(@"INDEX: %lu",index.unsignedLongValue);
        }
    }
    
    NSURL *textFile = [[SOTools tempDirectory] URLByAppendingPathComponent:@"testdata.txt"];
    
    [text writeToURL:textFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    return stringDict;
}

- (void)testStore:(SOTextStore *)store with:(NSDictionary *)stringDict;
{
    NSNumber *index = nil;
    NSString *dictString = nil;
    NSString *storeString = nil;
    
    for (index in stringDict) {
        dictString = [stringDict objectForKey:index];
        
        storeString = [store readStringAtIndex:index];
        
        if (![dictString isEqualToString:storeString]) {
            NSLog(@"ERROR INDEX: %lu",index.unsignedLongValue);
        }
        
        XCTAssertTrue([dictString isEqualToString:storeString],@"Is not the same?" );
    }
}

- (NSMutableDictionary *)readTextFile2:(NSString *)fileName inStore:(SOTextStore *)store;
{
    NSURL *textFile = [[SOTools tempDirectory] URLByAppendingPathComponent:fileName];
    NSMutableDictionary *stringDict = [NSMutableDictionary dictionary];
    
    NSString *text = [NSString stringWithContentsOfURL:textFile encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lineArray = [text componentsSeparatedByString:@"\r"];
    NSString *line = nil;
    
    for (line in lineArray) {
        NSNumber *index = [store addString:line];
        
        [stringDict setObject:line forKey:index];
    }
    
    return stringDict;
}

- (NSMutableDictionary *)readTextFile:(NSString *)fileName inStore:(SOTextStore *)store;
{
    NSURL *textFile = [[SOTools tempDirectory] URLByAppendingPathComponent:fileName];
    NSMutableDictionary *stringDict = [NSMutableDictionary dictionary];
    
    NSString *text = [NSString stringWithContentsOfURL:textFile encoding:NSUTF8StringEncoding error:nil];
    
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop){
        
        NSNumber *index = [store addString:line];
        
        [stringDict setObject:line forKey:index];
        
    }];
    
    return stringDict;
}

@end
