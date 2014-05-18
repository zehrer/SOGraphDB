//
//  SOIndexObject.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOTextIndexObject.h"

#import "SOStringData.h"

typedef struct {
    bool isUsed:1;
    bool isUTF8Encoding:1;
    bool _reserved3:1;
    bool _reserved4:1;
    bool _reserved5:1;
    bool _reserved6:1;
    bool _reserved7:1;
    bool _reserved8:1;
} HEADER;

typedef struct {
    unsigned long long pos;
    unsigned long length;

} RANGE;

@interface SOTextIndexObject () {

    HEADER  header;
    RANGE range;
}

@end

@implementation SOTextIndexObject

@synthesize id;
@synthesize isDirty;

#pragma mark - NSObject

+ (unsigned long)dataSize;
{
    return sizeof(HEADER) + sizeof(RANGE);
}

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        header.isUsed = YES;
        header.isUTF8Encoding = YES;
        range.pos = 0;
        range.length = 0;
        self.isDirty = YES; // TODO check
    }
    return self;
}

#pragma mark - SOIndexObject Properties

- (void)setUsed:(BOOL)used;
{
    if (used != header.isUsed) {
        header.isUsed = used;
        isDirty = YES;
    }
}

- (BOOL)isUsed;
{
    return header.isUsed;
}

- (void)setUTF8Encoding:(BOOL)value;
{
    if (header.isUTF8Encoding != value) {
        header.isUTF8Encoding = value;
        isDirty = YES;
    }
}

- (BOOL)isUTF8Encoding;
{
    return header.isUTF8Encoding;
}

- (void)setPos:(unsigned long long)aPos;
{
    if (range.pos != aPos) {
        range.pos = aPos;
        self.isDirty = YES;
    }
}

- (unsigned long long)pos;
{
    return range.pos;
}

- (void)setLength:(unsigned long)aLength;
{
    if (range.length != aLength) {
        range.length = aLength;
        self.isDirty = YES;
    }
}

- (unsigned long)length;
{
    return range.length;
}

- (void)setStringData:(SOStringData *)aStringData;
{
    if (_stringData != aStringData) {
        _stringData = aStringData;
        
        // just update string data paramter if not nil
        if (aStringData != nil) {
            [self setLength:aStringData.length];
            [self setUTF8Encoding:[aStringData isUTF8Encoding]];
        }
    }
}

#pragma mark - SOIndexObject Methodes

- (instancetype)initWithStringData:(SOStringData *)aStringData;
{
    self = [super init];
    if (self) {
        
        self.stringData = aStringData;  // update length and isUTF8Encoding
        
        self.pos = 0;
        header.isUsed = YES;
    }
    return self;
    
}

- (instancetype)initWithID:(NSUInteger)aID;
{
    self = [super init];
    if (self) {
        self.id  = [NSNumber numberWithUnsignedInteger:aID];
        self.isDirty = YES; // TODO check
    }
    return self;
}

- (instancetype)initWithIndexObject:(SOTextIndexObject *)aIndexObject;
{
    self = [super init];
    
        self.pos = aIndexObject.pos;
        self.length = aIndexObject.length;
    
        header.isUsed = NO; // mark as free space

    if (self) {
    }
    return self;
}

- (NSString *)decodeString:(NSData *)data;
{
    if (header.isUTF8Encoding) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
    }
    
}

#pragma mark - SOCoding

// add if required to support
- (instancetype)initWithData:(NSData *)data;
{
    return [self init];
}

- (NSData *)encodeData;
{
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&header length:sizeof(header)];
    
    [data appendBytes:&range length:sizeof(range)];
    
    return data;
}

- (void)decodeData:(NSFileHandle *)fileHandle;
{
    NSData *data = nil;
    
    long headerSize = sizeof(header);
    long rangeSize = sizeof(range);
    
    data = [fileHandle readDataOfLength:headerSize];
    [data getBytes:&header length:headerSize];

    data = [fileHandle readDataOfLength:rangeSize];
    [data getBytes:&range length:rangeSize];
    
    isDirty = NO;
}

@end
