//
//  SODataStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SODataStore.h"

//@property (nonatomic, strong, readonly) NSFileHandle *indexfileHandle;

@implementation SODataStore

#pragma mark

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        self.dataSize = 0;
        self.headerSize = 0;
    }
    return self;
}

#pragma mark - read/write header

- (NSData *)readHeader;
{
    return [self.fileHandle readDataOfLength:self.headerSize];
}

- (void)writeHeader;
{
    
}

- (void)readHeader:(void *)buffer;
{
    NSParameterAssert(self.headerSize);
    
    NSData *header = [self readHeader];
    [header getBytes:buffer length:self.headerSize];
}

- (void)writeHeader:(void *)buffer;
{
    NSParameterAssert(self.headerSize);
    
    NSData *header = [NSData dataWithBytes:buffer length:self.headerSize];
    [self.fileHandle writeData:header];
}

#pragma mark - pos Calcuation

- (unsigned long long)calculatePos:(NSNumber *)aID;
{
   return (aID.unsignedIntValue * self.dataSize) + self.fileOffset;
}

- (NSNumber *)calculateID:(unsigned long long)pos;
{
    unsigned long long result = (pos - self.fileOffset) / self.dataSize;

    return [NSNumber numberWithUnsignedLongLong:result]; // ignore warning
}

- (unsigned long long)seekToFileID:(NSNumber *)aID;
{
    NSParameterAssert(aID);
    
    unsigned long long pos = [self calculatePos:aID];
    
    [self.fileHandle seekToFileOffset:pos];
    
    return pos;
}

#pragma mark - SOFileStore

- (void)write:(NSData *)data atPos:(unsigned long long)pos;
{
    [self.fileHandle seekToFileOffset:pos];
    
    [self writeHeader];
    
    [self.fileHandle writeData:data];
}

- (unsigned long long)writeAtEndOfFile:(NSData *)data;
{
    unsigned long long pos = [self.fileHandle seekToEndOfFile];
    
    [self writeHeader];
    
    [self.fileHandle writeData:data];
    
    return pos;
}

#pragma mark - CRUD Data

- (NSNumber *)create:(NSData *)data;
{
    unsigned long long pos =  [self writeAtEndOfFile:data];
    
    return [self calculateID:pos];
}

- (NSData *)readData;
{
    return [self.fileHandle readDataOfLength:self.dataSize];
}

- (NSData *)readData:(NSUInteger)length;
{
    return [self.fileHandle readDataOfLength:length];
}

- (NSData *)read:(NSNumber *)aID;
{
    [self seekToFileID:aID];

    return [self readData];
}

- (void)update:(NSData *)data at:(NSNumber *)aID;
{

    [self seekToFileID:aID];
    
    [self writeHeader];
    
    [self.fileHandle writeData:data];
}

- (unsigned long long)delete:(NSNumber *)aID;
{
    unsigned long long pos = [self seekToFileID:aID];

    // subclass TODO :)
    
    return pos;
}

@end
