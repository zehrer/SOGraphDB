//
//  SOFileStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "NSNumber+SOCoreGraph.h"

#import "SOManagedDataStore.h"

typedef struct {
    bool isUsed:1;
    bool _reserved2:1;
    bool _reserved3:1;
    bool _reserved4:1;
    bool _reserved5:1;
    bool _reserved6:1;
    bool _reserved7:1;
    bool _reserved8:1;
} HEADER;

@interface SOManagedDataStore ()

@property (nonatomic) unsigned long long endOfFile;

@end

@implementation SOManagedDataStore

#pragma mark

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        _unusedDataSegments = [NSMutableSet set];
        
        HEADER header;
        header.isUsed = YES;
        
        self.header = [NSData dataWithBytes:&header length:sizeof(header)];
        
        header.isUsed = NO;
        self.deleteHeader = [NSData dataWithBytes:&header length:sizeof(header)];
        
        // set virtual file end to offSet because initStore use the register methode 
        self.endOfFile = self.fileOffset;
        
    }
    
    return self;
}

- (void)setupStore:(id<SOCoding>)aSampleObject;
{
    self.objectType = [aSampleObject class];
    
    self.sampleData = [aSampleObject encodeData];
    
    self.dataSize = self.sampleData.length + self.header.length;
    
    [self readUnusedDataSegments];
    
    [self initStore];
    
    self.endOfFile = [self endOfFile];
}

- (void)readUnusedDataSegments;
{
    unsigned long long end = [self.fileHandle seekToEndOfFile];
    unsigned long long pos = self.fileOffset;
    
    [self.fileHandle seekToFileOffset:pos];
    
    HEADER header;
    unsigned long headerSize = sizeof(header);
    
    NSData *aHeader = nil;
    
    while (pos < end) {
        // read the complete file
       aHeader = [self readHeader];
       [aHeader getBytes:&header length:headerSize];
        
       [self.fileHandle readDataOfLength:self.sampleData.length];
        
       if (!header.isUsed) {
           [self.unusedDataSegments addObject:[NSNumber numberWithLongLong:pos]];
       }
       pos = self.fileHandle.offsetInFile;
    }
}

// increase the virtual EndOfFile pointer by on dataSize
- (unsigned long long)extendFile;
{
    unsigned long long result = self.endOfFile;
    
    [self setEndOfFile:result + self.dataSize];
    
    return result;
}

// Create a file store element with the ID:0
// ID 0 is not allowd to use in the store because
// ID references to 0 are "NULL" pointer  
- (void)initStore;
{
    unsigned long long end = [self.fileHandle seekToEndOfFile];
    
    if (end == self.fileOffset) {
       // seems this file is new
       
       // store SampleData as ID:0 in the file
       // ID:0 is a reserved ID and should not be availabled for public access
       [self create:self.sampleData];
    }
}

#pragma mark - read/write Header

- (NSData *)readHeader;
{
    return [self.fileHandle readDataOfLength:self.header.length];
}

- (void)writeHeader;
{
    [self.fileHandle writeData:self.header];
}

#pragma mark - OVERRIDE SODataStore methodes

- (NSData *)readData;
{
    HEADER header;
    
    NSData *aHeader = [self readHeader];
    [aHeader getBytes:&header length:sizeof(header)];
    
    if (header.isUsed) {
        return [self.fileHandle readDataOfLength:self.sampleData.length];
    }
    
    return nil;
}

- (unsigned long long)delete:(NSNumber *)aID;
{
    unsigned long long pos = [super delete:aID];
    
    [self.fileHandle writeData:self.deleteHeader];
    [self.unusedDataSegments addObject:[NSNumber numberWithLongLong:pos]];
    
    return pos;
}

#pragma mark - CRUD Data

- (unsigned long long)register;
{
    unsigned long long pos = 0;
    
    NSNumber *unusedSegmentPos = [self.unusedDataSegments anyObject];
    
    if (unusedSegmentPos) {
        // if a unused segment is available, removed it for the index and return it.
        
        pos = unusedSegmentPos.unsignedLongLongValue;
        [self.unusedDataSegments removeObject:unusedSegmentPos];
    } else {
        pos = [self extendFile];
    }
 
    return pos;
}

- (NSNumber *)create:(NSData *)data;
{
    unsigned long long pos = [self register];

    [self write:data atPos:pos];

    return [self calculateID:pos];
}

#pragma mark - CRUD Objects

- (NSNumber *)registerObject:(id<SOCoding>)aObj;
{
    if ([aObj isDirty]) {
        // only NEW object can be registered, isDirty
        // flag don't show 100% if it is new but at least a information which is available
        unsigned long long pos = [self register];
        
        aObj.id = [self calculateID:pos];
        
        return aObj.id;
    }
    
    return nil;
}

@end
