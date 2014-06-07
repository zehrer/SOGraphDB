//
//  NSStoreCoder.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 29.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "NSStoreCoder.h"


// derived from CFNumberType
typedef NS_ENUM(UInt8, SONumberType) {
    kNSNumberSInt8Type = 1,
    kNSNumberSInt16Type = 2,
    kNSNumberSInt32Type = 3,
    kNSNumberSInt64Type = 4,
    kNSNumberFloat32Type = 5,
    kNSNumberFloat64Type = 6,	/* 64-bit IEEE 754 */
    /* Basic C types */
    kNSNumberCharType = 7,
    kNSNumberShortType = 8,
    kNSNumberIntType = 9,
    kNSNumberLongType = 10,
    kNSNumberLongLongType = 11,
    kNSNumberFloatType = 12,
    kNSNumberDoubleType = 13,
    /* Other */
    kNSNumberCFIndexType = 14,
    kNSNumberNSIntegerType = 15,
    kNSNumberCGFloatType = 16,
    kNSNumberMaxType = 16,
    /* */
    kNSNumberBoolType = 20,
    kNSDecimaNumberType = 21
};


@interface NSStoreCoder () {
    
    NSData *decodeData;
    SONumberType numberType;
}

@end

@implementation NSStoreCoder

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableData data];
    }
    return self;
}

- (BOOL)allowsKeyedCoding;
{
    return YES;
}

#pragma mark - NSStoreCoder

#pragma mark encode


+ (NSMutableData *)encodeNSNumber:(NSNumber *)aNumber;
{
    NSStoreCoder *coder = [[NSStoreCoder alloc] init];
    
    [coder encodeNSNumber:aNumber];
    
    return [coder encodeData];
}

- (instancetype)initForWritingWithMutableData:(NSMutableData *)data;
{
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (void)encodeRootObject:(id<NSCoding>)aObject;
{
    
    [aObject encodeWithCoder:self];
}

- (NSMutableData *)encodeData;
{
    return self.data;
}


- (void)encodeNSNumber:(NSNumber *)aNumber;
{
    [aNumber encodeWithCoder:self];
}

- (void)encodeNSDecimalNumber:(NSDecimalNumber *)aNumber;
{
    //NSDecimal value;
    //memcpy ( &value, &property.buffer, sizeof(value) );
    //self.data = [[NSDecimalNumber alloc] initWithDecimal:value];
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
{
    SONumberType type = kNSNumberBoolType;
    
    [self.data appendBytes:&type length:sizeof(type)];
    [self.data appendBytes:&boolv length:sizeof(boolv)];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key;
{
    SONumberType type = kNSNumberDoubleType;
    
    [self.data appendBytes:&type length:sizeof(type)];
    [self.data appendBytes:&realv length:sizeof(realv)];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key;
{
    SONumberType type = kNSNumberSInt32Type;
    
    [self.data appendBytes:&type length:sizeof(type)];
    [self.data appendBytes:&intv length:sizeof(intv)];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key;
{
    SONumberType type = kNSNumberSInt64Type;
    
    [self.data appendBytes:&type length:sizeof(type)];
    [self.data appendBytes:&intv length:sizeof(intv)];
}


#pragma mark - decode


- (NSNumber *)decodeNSNumber:(NSData *)data;
{
    decodeData = data;
    
    // decode type;
    [decodeData getBytes:&numberType length:sizeof(numberType)];
    
    NSNumber *result = [[NSNumber alloc] initWithCoder:self];
    
    decodeData = nil;
    
    return result;
}



- (BOOL)containsValueForKey:(NSString *)key;
{
    NSLog(@"KEY: %@",key);
    
    switch (numberType) {
        case kNSNumberBoolType:
            if ([@"NS.boolval" isEqualToString:key])
                return YES;
            break;
            
        case kNSNumberSInt64Type:
            if ([@"NS.intval" isEqualToString:key])
                return YES;
            
        case kNSNumberDoubleType:
            if ([@"NS.dblval" isEqualToString:key])
                return YES;
            break;
        default:
            break;
    }
    
    //@"NS.intval"
    // NS.boolval
    // NS.number
    // NS.dblval
    
    return NO;
}


- (int64_t)decodeInt64ForKey:(NSString *)key;
{
    int64_t value;
    
    NSRange range = NSMakeRange(1, sizeof(value));
    
    [decodeData getBytes:&value range:range];
    
    return value;
}

- (BOOL)decodeBoolForKey:(NSString *)key;
{
    BOOL value;
    
    NSRange range = NSMakeRange(1, sizeof(value));
    
    [decodeData getBytes:&value range:range];
    
    return value;
}

- (double)decodeDoubleForKey:(NSString *)key;
{
    double value;
    
    NSRange range = NSMakeRange(1, sizeof(value));
    
    [decodeData getBytes:&value range:range];
    
    return value;
}




#pragma mark - NSCoder

// NSCoder
- (void)encodeObject:(NSData *)data;
{
    NSLog(@"TEST");
}



// NSCoder
- (void)decodeValueOfObjCType:(const char *)type at:(void *)data;
{
    //NSUInteger length = 0;
    
    //NSGetSizeAndAlignment(type, &length, NULL);
    
}



// NSCoder
- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr;
{
    NSUInteger length = 0;
    
    NSGetSizeAndAlignment(type, &length, NULL);
    
    // strcmp
    
    //size_t len;
    const char* text;
    NSString *aText;
    
    switch (type[0])
    {
        case '*':
            // A character string (char *)
            // IGNORE chars
            
            //len = strlen(addr);
            text = addr;
            
            aText = [[NSString alloc] initWithUTF8String:text];
            
            NSLog (@"%s",text);
            
            break;
        case 'c':
            // A char
        case 'C':
            // An unsigned char
        case 's':
            // A short
        case 'S':
            // An unsigned short
        case 'i':
            // An int
        case 'I':
            // An unsigned int
        case 'l':
            // A long
        case 'L':
            // An unsigned long
        case 'q':
            // A long long
        case 'Q':
            // An unsigned long long
        case 'f':
            // A float
        case 'd':
            // A double
        case 'B':
            // A C++ bool or a C99 _Bool
            
            [self.data appendBytes:addr length:length];
            break;
            
        default:
            [NSException raise: NSInvalidArgumentException
                        format: @"unrecognised type for compare:"];
            
    }
    
}

@end
