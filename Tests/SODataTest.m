//
//  SODataTest.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

@import XCTest;
@import SOGraphDB;
@import MapKit;

typedef struct {
    bool inUse;  // 1
}TEST1;

typedef struct {
    unsigned int nextPropID;  // 4
}TEST2;

typedef struct {
    unsigned int nextPropID; // 4
    unsigned int nextRelID;  // 4
}TEST3;

typedef struct {
    bool inUse;              // 1
    char _reserved1;         // 1
    char _reserved2;         // 1
    char _reserved3;         // 1
    unsigned int nextPropID; // 4
    unsigned int nextRelID;  // 4
}TEST4;  // 12 byte

@interface SODataTest : XCTestCase

@end

@implementation SODataTest


// types.h
 
// number types

// char             : 1
// signed char      : 1 (BOOL)   see objc.h
// unsigned char    : 1

// short int        : 2
// int              : 4
// unsigned int     : 4

// NSInteger        : 8 (long)
// NSUInteger       : 8 (unsigned long || unsigned int

// float            : 4
// double           : 8

// NSTimeInterval   : 8 (double)

// NSDecimal        : 20

/**
 signed   int _exponent:8;
 unsigned int _length:4;     // length == 0 && isNegative -> NaN
 unsigned int _isNegative:1;
 unsigned int _isCompact:1;
 unsigned int _reserved:18;
 */

typedef struct {
    bool is8BitEncoding:1;
    bool isInUse:1;
    unsigned char _reserved:6;
}TEST5;

- (void)test4Size
{
    TEST5 test;
    
    test.is8BitEncoding = YES;
    test.isInUse = YES;
    test.is8BitEncoding = NO;
    test.isInUse = NO;
    
    NSLog(@"********* Size: %lu", sizeof(TEST5));
}


- (void)test1SizeOfBasicTypes;
{
    long long dataLongLong;
    XCTAssertTrue(sizeof(dataLongLong) == 8 , @"size error");
    
    long dataLong;
    XCTAssertTrue(sizeof(dataLong) == 8 , @"size error");

    unsigned long dataULong;
    XCTAssertTrue(sizeof(dataULong) == 8 , @"size error");
    
    unsigned long long dataULongLong;
    XCTAssertTrue(sizeof(dataULongLong) == 8 , @"size error");
    
    short int dataShortInt;
    XCTAssertTrue(sizeof(dataShortInt) == 2 , @"size error");
    
    int dataInt;
    XCTAssertTrue(sizeof(dataInt) == 4 , @"size error");
    
    // NSUInteger
    unsigned int dataUInt;
    XCTAssertTrue(sizeof(dataUInt) == 4 , @"size error");
    
    char dataChar;
    XCTAssertTrue(sizeof(dataChar) == 1 , @"size error");
    
    signed char dataSChar;
    XCTAssertTrue(sizeof(dataSChar) == 1 , @"size error");

    unsigned char dataUChar;
    XCTAssertTrue(sizeof(dataUChar) == 1 , @"size error");
    
    float dataFloat;
    XCTAssertTrue(sizeof(dataFloat) == 4 , @"size error");
    
    double dataDouble;
    XCTAssertTrue(sizeof(dataDouble) == 8 , @"size error");
}

/**
- (void)test1SizeOfDate;
{
    NSDate *date = [[NSDate alloc]init];
    
    NSTimeInterval dataDate = [date timeIntervalSinceReferenceDate];
    
    XCTAssertTrue(sizeof(dataDate) == 8 , @"size error");
    
    NSData *newData = [NSDate dateWithTimeIntervalSinceReferenceDate:dataDate];
    
    XCTAssertTrue([newData isEqual:date], @"not the same result?");
}
 */


- (void)test1SizeOfDezimal;
{
    NSDecimal dataDezimal;
    
    NSLog(@"Size: %lu", sizeof(dataDezimal));
    XCTAssertTrue(sizeof(dataDezimal) == 20 , @"size error");
}

- (void)test1UUID;
{
    NSUUID *uuid = [NSUUID UUID];
    
    uuid_t dataUUID;
    
    [uuid getUUIDBytes:dataUUID];
    
    XCTAssertTrue(sizeof(dataUUID) == 16 , @"size error");
    
    NSLog(@"data: %s", dataUUID);
}

- (void)test1String;
{
    NSString *text = @"01234567890123456789";
    
    bool isUTF8 = [text canBeConvertedToEncoding:NSUTF8StringEncoding];
    NSData *dataString = nil;
    
    if (isUTF8) {
        dataString = [text dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        dataString = [text dataUsingEncoding:NSUnicodeStringEncoding];
    }
    
    // NSUTF8StringEncoding     <- 8
    // NSUnicodeStringEncoding  <- 16
    
    NSLog(@"Size: %lu", dataString.length);
    

}

- (void)test1Range;
{
    NSRange dataRange;
    
    //NSLog(@"Size: %lu", sizeof(dataRange));
    XCTAssertTrue(sizeof(dataRange) == 16 , @"size error");
}

- (void)test1NSNumber;
{
    NSNumber *num = [NSNumber numberWithUnsignedLong:INT_MAX];
    
    SOID test = [num ID];
    
    NSLog(@"Value: %u", test);
    //XCTAssertTrue(sizeof(dataRange) == 16 , @"size error");
}

- (void)test2UTF16String;
{
    NSString *text = @"\u6523\u6523\u6523\u6523";   // \

    NSLog(@"Text: -%@-", text);
    
    bool isUTF8 = [text canBeConvertedToEncoding:NSUTF8StringEncoding];
    NSLog(@"UTF8: %u",isUTF8);
    
    NSData *stringUTF8 = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stringUTF16 = [text dataUsingEncoding:NSUTF16StringEncoding];
    NSData *stringUTF32  = [text dataUsingEncoding:NSUTF32StringEncoding];
    
    // NSUTF8StringEncoding     <- 8
    // NSUnicodeStringEncoding  <- 16
    
    NSLog(@"Size UTF-8  : %lu", stringUTF8.length);
    NSLog(@"Size UTF-16 : %lu", stringUTF16.length);
    NSLog(@"Size UTF-32 : %lu", stringUTF32.length);
    
    NSString *newText = [[NSString alloc] initWithData:stringUTF16 encoding:NSUTF16StringEncoding];
    
    if ([newText isEqualToString:text])
    {
        NSLog(@"Equal text: -%@-", newText);
    }
    
}

- (void)test3EncodingType;
{
    const char* typeint     = @encode(int);
    NSLog(@"Type Int : %s", typeint);
    
    const char* typelong    = @encode(long);
    NSLog(@"Type Long : %s", typelong);
    
    const char* typeString = @encode(NSString);
    NSLog(@"Type String : %s", typeString);
    
    
    if (typeint == typelong) {
        NSLog(@"ERROR");
    }
    
    const char* test        = @encode(int);
    if (typeint == test) {
        NSLog(@"OK");
    }

    
}


- (void)test3Encoding;
{
    NSNumber *num = [NSNumber numberWithLong:42];

    const char * type = num.objCType;
    
    NSLog(@"Size : %lu", strlen(type));
    
    NSLog(@"Type -%s-",num.objCType);
    
    NSLog(@"Type -%ld-",[num longValue]);
    
    //NSData *data []
    
}

- (void)test4NSValue;
{
    NSNumber *num = [NSDecimalNumber maximumDecimalNumber];
    
    NSUInteger bufferSize = 0;
    
    NSGetSizeAndAlignment([num objCType], &bufferSize, NULL);
    
    void* buffer = malloc(bufferSize);
    
    [num getValue:buffer]; //notice the lack of '&'
    
    NSMutableData *data =  [NSMutableData dataWithBytesNoCopy:buffer length:bufferSize];
    
    NSLog(@"Size %lu", (unsigned long)data.length);
    
}

// MKCoordinateSpan
- (void)test90MapKit1;
{
    MKCoordinateSpan data1;
    XCTAssertTrue(sizeof(data1) == 16 , @"size error");
    
    MKCoordinateRegion data2;
    XCTAssertTrue(sizeof(data2) == 32 , @"size error");
}

- (void)test95Size
{
    SONode *aNode = [[SONode alloc] init];
    NSData *nodeData = [aNode encodeData];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:nodeData];
    
    //NSUUID *uuid = [NSUUID UUID];
    NSLog(@"********* Size: %lu", data.length);
}


- (void)test0BasicTest
{
    char *buf1 = @encode(BOOL);
    
    NSLog(@" %s", buf1);
}


- (void)test96Cache
{
    SONode *aNode = [[SONode alloc] init];
   
    NSCache *cache = [[NSCache alloc] init];
    
    NSNumber *aID = [NSNumber numberWithUnsignedInteger:1];
    
    [cache setObject:aNode forKey:aID];
    
    
    id test = [cache objectForKey:[NSNumber numberWithUnsignedInteger:1]];
    
    XCTAssertNotNil(test, @"no value returend from cache");
}

@end
