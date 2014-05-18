//
//  SOProperty.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOGraphContext.h"

#import "NSValue+SOCoreGraph.h"

#import "NSNumber+SOCoreGraph.h"

#import "NSStoreCoder.h"

#import "SOStringData.h"

#import "SOProperty.h"

#import "SONode.h"

typedef char byte;

typedef NS_ENUM(UInt8, SODataType) {
    kUndefined,
    kBoolType,
    kLongType,
    kUnsignedLongType,
    kDoubleType,
    kNSStringType,
    //kNSNumberType,
    //    kNSDataType,
    //    kSOIDType,
    //    kNSDateType,
    //    kNSPointType,
    //    kNSRangeType,
    kNSDecimalType,
    kNSUUIDType
    //    kNSURLType  // may not work
};


typedef struct {
    
    bool isNodeSource;            // 1Byte   <- yes = property of a node / no = property of a relationship
    bool isUTF8Encoding;          // 1  <- yes internal string usues UTF8 / NO == UTF16
    UInt8 bufferLength;           // 1Byte

    SODataType type;              // 1
    
    SOID sourceID;                // 4  <- link to the source object
    
    SOID propertyKeyNodeID;       // 4  <- "type" of this property
    
    SOID prevPropertyID;          // 4  <- 0 if start
    SOID nextPropertyID;          // 4  <- 0 if end
        
} PROPERTY;  // 20

#define BUFFER_LEN 20


@interface SOProperty () {
    
    PROPERTY property;
    NSUInteger stringHash;

    NSNumber *stringStoreID;
}

@property (nonatomic, strong) id data;

@end

@implementation SOProperty

- (instancetype)initWithElement:(SOPropertyAccessElement *)element;
{

    self = [super init];
    if (self) {
        //NSUInteger size = sizeof(property);
        self.isDirty = YES;
        
        if ([element isKindOfClass:[SONode class]]) {
             property.isNodeSource = YES;
        } else {
            property.isNodeSource = NO;
        }
        
        property.sourceID = [element.id ID];
       
        property.isUTF8Encoding = YES;
        property.bufferLength = BUFFER_LEN;
        
        property.propertyKeyNodeID = 0;
        
        property.prevPropertyID = 0;
        property.nextPropertyID = 0;
        
        property.type = kUndefined;
    }
    
    return self;
}

#pragma mark - SOCoding

- (instancetype)initWithData:(NSData *)aData;
{
    self = [super initWithData:aData];
    {
        [aData getBytes:&property length:sizeof(property)];
        
        NSData *dataBuffer = [self extractDataBuffer:aData];
        
        switch (property.type) {
            case kBoolType:
            case kLongType:
            case kUnsignedLongType:
            case kDoubleType:
            {
                // NSStoreCoder handled some NSNumber types
                NSStoreCoder *coder = [[NSStoreCoder alloc]init];
                self.data = [coder decodeNSNumber:dataBuffer];
            }
                break;
            case kNSDecimalType:
            {
                NSDecimal value;
                [dataBuffer getBytes:&value length:sizeof(value)];
                self.data = [[NSDecimalNumber alloc] initWithDecimal:value];
            }
                break;
            case kNSUUIDType:
            {
                uuid_t value;
                [dataBuffer getBytes:&value length:sizeof(value)];
                self.data = [[NSUUID alloc] initWithUUIDBytes:value];
            }
                break;
            case kNSStringType:
            {
                SOID aID;
                [dataBuffer getBytes:&aID length:sizeof(aID)];
                
                stringStoreID = [NSNumber numberWithID:aID];
            }
                break;
            case kUndefined:
                break;
        }
        
    }
    return self;
}

- (NSData *)encodeData;
{
    NSData *dataBuffer = nil;

    // TODO handling for NSDecimalNumber (subclass of NSNumber)
    if ([self.data isKindOfClass:[NSNumber class]]) {
        
        // NSNumber
        
        dataBuffer = [NSStoreCoder encodeNSNumber:self.data];
        
    } else if ([self.data isKindOfClass:[NSString class]]) {
        
        // NSString
        
        SOStringData *stringData = [[SOStringData alloc] initWithString:self.data];
        property.isUTF8Encoding = [stringData isUTF8Encoding];
        
        NSNumber *stringID = [self.context addString:self.data];
        dataBuffer = [stringID encode];
    }
    
    NSAssert(dataBuffer.length <= BUFFER_LEN, @"Data is to big");
    property.bufferLength = dataBuffer.length;  // store the original buffer length
    
    // Init with PROPERTY data  (which will be updated above)
    NSMutableData *data = [NSMutableData dataWithBytes:&property length:sizeof(property)];
    
    // data from self.data
    [data appendData:dataBuffer];
    
    // extend the buffer to standard size (if required)
    [data setLength:BUFFER_LEN + sizeof(property)];
    
    return data;
}

#pragma mark - SOProperty

- (void)delete;
{
    [[self context] deleteProperty:self];
}

- (void)update;
{
    if (self.isDirty) {
        if (property.type == kNSStringType) {
            stringStoreID = [self.context addString:self.data];
        }
        
        [[self context] updateProperty:self];
    }
}

- (NSData *)extractDataBuffer:(NSData *)aData;
{
    NSRange bufferRange = NSMakeRange(sizeof(property), property.bufferLength);
    
    return [aData subdataWithRange:bufferRange];
}

#pragma mark - Basic Types

#pragma mark BOOL

- (void)setBoolValue:(BOOL)value;
{
    if ([self.data boolValue] != value) {
        
        NSParameterAssert(sizeof(value) <= BUFFER_LEN);
        
        self.data = [[NSNumber alloc] initWithBool:value];
        property.type = kBoolType;
        self.isDirty = YES;
    }
}

- (BOOL)boolValue;
{
    return [self.data boolValue];
}

#pragma mark Long

- (void)setLongValue:(long)value;
{
    if ([self.data longValue] != value) {
        
        NSParameterAssert(sizeof(value) <= BUFFER_LEN);
        
        self.data = [[NSNumber alloc] initWithLong:value];
        property.type = kLongType;
        self.isDirty = YES;
    }
}

- (long)longValue;
{
    return [self.data longValue];
}

#pragma mark UnsignedLong

- (void)setUnsignedLongValue:(unsigned long)value;
{
    if ([self.data unsignedLongValue] != value) {
        
        NSParameterAssert(sizeof(value) <= BUFFER_LEN);
        
        self.data = [[NSNumber alloc] initWithUnsignedLong:value];
        property.type = kUnsignedLongType;
        self.isDirty = YES;
    }
}

- (unsigned long)unsignedLongValue;
{
    return [self.data unsignedLongValue];
}

#pragma mark Double

- (void)setDoubleValue:(double)value;
{
    if ([self.data doubleValue] != value) {
        
        NSParameterAssert(sizeof(value) <= BUFFER_LEN);
        
        self.data = [[NSNumber alloc] initWithDouble:value];
        property.type = kDoubleType;
        self.isDirty = YES;
    }
}

- (double)doubleValue;
{
    return [self.data doubleValue];
}

#pragma mark - NSString

- (void) setStringValue:(NSString *)stringValue;
{
    NSUInteger hash = [stringValue hash];
    
    if (stringHash != hash) {
        property.type = kNSStringType;
        self.data = stringValue;
        stringHash = hash;
        self.isDirty = YES;
    }
}

- (NSString *)stringValue;
{
    switch (property.type) {
        case kNSStringType: {
            if (self.data == nil) {
                self.data = [self.context readStringAtIndex:stringStoreID];
                stringHash = [self.data hash];
            }
            
            return self.data;
        }
        case kBoolType:
        case kLongType:
        case kUnsignedLongType:
        case kDoubleType:
        case kNSUUIDType:
        case kUndefined:
        case kNSDecimalType:
            break;
    }
    
    return nil;
}

#pragma mark - Internal

- (BOOL)isNodeSource;
{
    return property.isNodeSource;
}

- (NSNumber *)sourceID;
{
    return [NSNumber numberWithID:property.sourceID];
}

- (void)setNextPropertyID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != property.nextPropertyID) {
        property.nextPropertyID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)nextPropertyID;
{
    if (property.nextPropertyID > 0) {
        return [NSNumber numberWithID:property.nextPropertyID];
    }
    
    return nil;
}

- (void)setPreviousPropertyID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != property.prevPropertyID) {
        property.prevPropertyID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)previousPropertyID;
{
    if (property.prevPropertyID > 0) {
        return [NSNumber numberWithID:property.prevPropertyID];
    }
    
    return nil;
}

- (void)setKeyNodeID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != property.propertyKeyNodeID) {
        property.propertyKeyNodeID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)keyNodeID;
{
    return [NSNumber numberWithID:property.propertyKeyNodeID];
}

@end

