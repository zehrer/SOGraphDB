//
//  SOFileStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOFileStore.h"

@implementation SOFileStore

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [self init];
    if (self) {
        
        NSError *error;
        
        _url    = url;
        _fileHandle = [NSFileHandle fileHandleForUpdatingURL:url error:&error];
        
        _isNewFile = NO;
        
        self.fileOffset = 1;
        
        if (!_fileHandle) {
            // if not exists -> create file
            
            [self createNewFile:&error];
            
            _isNewFile = YES;
            
            error = nil; // remove file not found error
            _fileHandle = [NSFileHandle fileHandleForUpdatingURL:url error:&error];
        }
        
        // TODO: improve error handling: what are possible errors for file operation?
        _error = error;        
    }
    
    return self;
}

- (void)createNewFile:(NSError **)errorPtr;
{
    // file offset
    char first = 'A';
    NSData *data = [NSData dataWithBytes:&first length:sizeof(first)];
    [data writeToURL:self.url options:NSDataWritingAtomic error:errorPtr];
}

#pragma mark - CRUD Data

- (unsigned long long)endOfFile;
{
    return [self.fileHandle seekToEndOfFile];
}

- (void)write:(NSData *)data atPos:(unsigned long long)pos;
{
    [self.fileHandle seekToFileOffset:pos];
    
    [self.fileHandle writeData:data];
}

- (unsigned long long)writeAtEndOfFile:(NSData *)data;
{
    unsigned long long pos = [self.fileHandle seekToEndOfFile];
    
    [self.fileHandle writeData:data];
    
    return pos;
}

- (NSData *)read:(NSUInteger)length atPos:(unsigned long long)pos;
{
    [self.fileHandle seekToFileOffset:pos];
    
    return [self.fileHandle readDataOfLength:length];
}

@end
