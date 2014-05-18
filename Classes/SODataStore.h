//
//  SODataStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOFileStore.h"

#import "SOCoding.h"

/**
 * This is an abstract super class which fulfil the following requirements:
 * - add inital header handling
 * - minor data handling
 * - inital object handling
 */
@interface SODataStore : SOFileStore

#pragma mark - 

@property (nonatomic) unsigned long dataSize; // default is 0;
@property (nonatomic) unsigned long headerSize;  //default is 0;

// SEE SOFileStore Remeber to override this methode
// - (void)createNewFile:(NSError **)errorPtr;

#pragma mark - Position

- (unsigned long long)calculatePos:(NSNumber *)aID;
- (NSNumber *)calculateID:(unsigned long long)pos;

- (unsigned long long)seekToFileID:(NSNumber *)aID;

#pragma mark - SOFileStore

// write data directly to the pos
// this class override this method to add header support
//- (void)write:(NSData *)data atPos:(unsigned long long)pos;

// move the fileHandler to the end of the file and
// write the data and calc the new ID for it
// This class override this method to add header support
//- (unsigned long long)writeAtEndOfFile:(NSData *)data;

#pragma mark - SubClass Extension

- (NSData *)readHeader;
- (void)writeHeader;

- (void)readHeader:(void *)buffer;
- (void)writeHeader:(void *)buffer;

// this is called within the read methode
// subclases can override this methode to process the data
- (NSData *)readData;
- (NSData *)readData:(NSUInteger)length;

// OVERRIDE: subclasses have to override this methode
// this methode move fileHandle to the correct possition
- (unsigned long long)delete:(NSNumber *)aID;

#pragma mark - CRUD Data

// This methode just write the data at the end of the file
// OVERRIDE: subclasses should override the methode add space management
- (NSNumber *)create:(NSData *)data;

// move the fileHander to the correct possition and read data if size: dataSize
- (NSData *)read:(NSNumber *)aID;

// move the fileHalder to the correct possition and (over) write the data
- (void)update:(NSData *)data at:(NSNumber *)aID;


@end
