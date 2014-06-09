//
//  NSStoreCoderTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 29.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <XCTest/XCTest.h>

@import SOGraphDB;

@interface NSStoreCoderTest : XCTestCase

@end

@implementation NSStoreCoderTest

- (void)test1Long
{
    NSNumber *num = [NSNumber numberWithLong:LONG_MAX];

    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}

- (void)test1ULong
{
    NSNumber *num = [NSNumber numberWithUnsignedLong:LONG_MAX];
    
    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}

- (void)test1Bool
{
    NSNumber *num = [NSNumber numberWithBool:YES];
    
    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}

- (void)test1Double
{
    NSNumber *num = [NSNumber numberWithDouble:42.42];
    
    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}

- (void)test1Float
{
    NSNumber *num = [NSNumber numberWithFloat:-42.42];
    
    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}

/**
- (void)test1Decimal
{
    NSDecimalNumber *num = [NSDecimalNumber one];
    
    NSData *data = [NSStoreCoder encodeNSNumber:num];
    
    NSStoreCoder *coder = [[NSStoreCoder alloc]init];
    
    NSNumber *test = [coder decodeNSNumber:data];
    
    XCTAssertTrue([test isEqual:num], @"Not the same number");
}
*/

@end
