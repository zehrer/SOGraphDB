//
//  SOStringDataStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "NSNumber+SOCoreGraph.h"

#import "SOStringData.h"

#import "SOStringDataStore.h"

typedef struct {
    bool isUsed:1;               // 1
    bool isUTF8Encoding:1;       // 1  <- yes string usues UTF8 / NO == UTF16
    bool _reserved3:1;
    bool _reserved4:1;
    bool _reserved5:1;
    bool _reserved6:1;
    bool _reserved7:1;
    bool _reserved8:1;           // 1Byte
    UInt8 bufferLength;          // 1Byte
    SOID nextStringID;           // 4  <- 0 if no further block
    NSUInteger stringHash;       // 8  <- is only set in startblock otherwise 0
} HEADER; // 16 ??

#define BUFFER_LEN 34

@interface SOStringDataStore ()

@property (nonatomic) unsigned long long endOfFile;

@end

@implementation SOStringDataStore

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        _unusedDataBlocks = [NSMutableSet set];
        _stringHashIndex = [NSMutableDictionary dictionary];
        
        HEADER header;
        self.headerSize = sizeof(header);
        self.dataSize = self.headerSize + BUFFER_LEN;
        
        // set virtual file end to offSet because initStore use the register methode
        self.endOfFile = self.fileOffset;
        
        if (self.isNewFile) {
            [self initStore];
        } else {
            [self readUnusedDataSegments];
        }
        
        self.endOfFile = [self endOfFile];
    }
    
    return self;
}

- (void)initStore;
{
    // write block 0
    NSString *text = @"v1.0 String Store (c) S. Zehrer";
    SOStringData *stringData = [[SOStringData alloc] initWithString:text];
    [self createBlock:stringData withID:0];
}


- (void)readUnusedDataSegments;
{
    unsigned long long end = [self.fileHandle seekToEndOfFile];
    unsigned long long pos = [self calculatePos:[NSNumber numberWithID:1]];
    
    [self.fileHandle seekToFileOffset:pos];
    
    HEADER header;
    
    while (pos < end) {
        [self readHeader:&header];
        
        [self.fileHandle readDataOfLength:BUFFER_LEN];
        
        // read unusedDataBlock
        if (!header.isUsed) {
            [self.unusedDataBlocks addObject:[NSNumber numberWithLongLong:pos]];
        }
        
        // read stringHashIndex
        if (header.stringHash > 0) {
            NSNumber *index = [self calculateID:pos];
            NSNumber *hash = [NSNumber numberWithUnsignedLong:header.stringHash];
            [self.stringHashIndex setObject:index forKey:hash];
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

#pragma mark - CRUD Data

- (unsigned long long)register;
{
    unsigned long long pos = 0;
    
    NSNumber *unusedSegmentPos = [self.unusedDataBlocks anyObject];
    
    if (unusedSegmentPos) {
        // if a unused segment is available, removed it for the index and return it.
        
        pos = unusedSegmentPos.unsignedLongLongValue;
        [self.unusedDataBlocks removeObject:unusedSegmentPos];
    } else {
        pos = [self extendFile];
    }
    
    return pos;
}

- (NSNumber *)create:(NSData *)data;
{
    unsigned long long pos = [self register];
    
    [self.fileHandle seekToFileOffset:pos];
    
    [self.fileHandle writeData:data];
    
    return [self calculateID:pos];
}

- (unsigned long long)delete:(NSNumber *)aID;
{
    HEADER header;
    
    unsigned long long pos = [self seekToFileID:aID];
   
    [self readHeader:&header];
    
    if (header.nextStringID > 0) {
        [self delete:[NSNumber numberWithID:header.nextStringID]];
    }
    
    header.isUsed = NO;
    header.stringHash = 0;
    header.nextStringID = 0;
    
    [self seekToFileID:aID];
    [self writeHeader:&header];
    
    return pos;
}

/**
 * The following pre-conditions are relevant:
 * - stringData is mandatory
 * - stringHash is optional -> otherwise 0;
 * - nextID is optional -> otherwise 0;
 *
 * Possible options
 * - First Block
 *   -> stringHash is mandatory
 *   -> nextID is the reference to the next block or 0 for the end
 
 * - Further Block
 *   -> stringHash is 0
 *   -> nextID is the refernece to the next block or 0 for the end
 */
- (NSNumber *)createBlock:(SOStringData *)stringData withID:(SOID)nextID;
{
    HEADER header;
    header.stringHash = stringData.hash;
    header.nextStringID = nextID;
    header.isUTF8Encoding = [stringData isUTF8Encoding];
    
    header.isUsed = YES;
    header.bufferLength = stringData.length;
    
    // Init with PROPERTY data  (which will be updated above)
    NSMutableData *data = [NSMutableData dataWithBytes:&header length:self.headerSize];
    
    // data from self.data
    [data appendData:stringData.data];
    
    // extend the buffer to standard size (if required)
    [data setLength:self.dataSize];
    
    return [self create:data];
}

// Return the index of the firstBlock
- (NSNumber *)createBlocks:(SOStringData *)stringData;
{
    NSNumber *result = nil;
    
    if (stringData.length > BUFFER_LEN) {
        // split
    } else {
        result = [self createBlock:stringData withID:0];
    }
    
    return result;
}

#pragma mark - SOStringStore

// This methode either add a new string to the store or return the ID if the existing one
- (NSNumber *)addString:(NSString *)text;
{
    NSNumber *hash = [NSNumber numberWithUnsignedLong:[text hash]];
    NSNumber *index = [self.stringHashIndex objectForKey:hash];
    
    if (index == nil) {
        // string seems not in the store
        
        SOStringData *stringData = [[SOStringData alloc] initWithString:text];
        
        index = [self createBlocks:stringData];
        [self.stringHashIndex setObject:index forKey:hash];
    }
    
    return index;
}

// This methode return the string at the specified indexs
- (NSString *)readStringAtIndex:(NSNumber *)aIndex;
{
    [self seekToFileID:aIndex];
    
    HEADER header;
    [self readHeader:&header];
    
    NSString *result = nil;
    
    if (header.isUsed) {
        NSData *data = [self readData:header.bufferLength];
        result = [SOStringData decodeData:data withUTF8:header.isUTF8Encoding];
    }
    
    return result;
}

- (void)deleteStringAtIndex:(NSNumber *)aIndex;
{
    [self delete:aIndex];
}

@end
