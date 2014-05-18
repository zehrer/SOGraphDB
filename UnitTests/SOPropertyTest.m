//
//  SOPropertyTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 28.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOCoreGraph/SOProperty.h>

#import <XCTest/XCTest.h>

@interface SOPropertyTest : XCTestCase

@end

@implementation SOPropertyTest

- (void)test1BoolValue1
{
    SOProperty *property = [[SOProperty alloc] init];
    
    bool test = property.boolValue;
    
     XCTAssertFalse(test, @"false not default value");
}

- (void)test1BoolValue2
{
    SOProperty *property = [[SOProperty alloc] init];
    
    property.boolValue = YES;
    
    bool test = property.boolValue;
    
    XCTAssertTrue(test, @"value not set?");
}

- (void)test2EncodeBool
{
    SOProperty *property = [[SOProperty alloc] init];
    
    property.boolValue = YES;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    bool test = property.boolValue;
    
    XCTAssertTrue(test, @"value not encoded");
}

- (void)test2EncodeLong
{
    SOProperty *property = [[SOProperty alloc] init];
    
    property.longValue = LONG_MAX;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    long test = property.longValue;
    
    XCTAssertEqual(test, LONG_MAX, @"value not encoded");
}

- (void)test2EncodeUnsignedLong
{
    SOProperty *property = [[SOProperty alloc] init];
    
    property.unsignedLongValue = LONG_MAX;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    unsigned long test = property.unsignedLongValue;
    
    XCTAssertTrue(test == LONG_MAX, @"value not encoded");
}

- (void)test2EncodeDouble;
{
    SOProperty *property = [[SOProperty alloc] init];
    
    property.doubleValue = 42.42;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    double test = property.doubleValue;
    
    XCTAssertTrue(test == 42.42, @"value not encoded");
}
/**

- (void)test2EncodeString20;
{
    NSString *testData = @"01234567890123456789";
    
    SOProperty *property = [[SOProperty alloc] init];
    
    property.stringValue = testData;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    NSString *text = property.stringValue;
    
    XCTAssertTrue([testData isEqualToString:text], @"value not encoded");
}

- (void)test2EncodeString10;
{
    NSString *testData = @"01234567890";
    
    SOProperty *property = [[SOProperty alloc] init];
    
    property.stringValue = testData;
    
    NSData *data = [property encodeData];
    
    property = [[SOProperty alloc] initWithData:data];
    
    NSString *text = property.stringValue;
    
    XCTAssertTrue([testData isEqualToString:text], @"value not encoded");
}
 */

@end
