//
//  SOFileStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

/**
 *  (Abstract) Superclass for file store handling which fulfil the following requirements
 *  - it manage the NSFileHandler for
 *  - open file
 *  - create new file (if required)
 *  - provide simple CRUD methode for NSData
 *  - fileOffset -> setup in init methode and return 1
 */
@interface SOFileStore : NSObject

@property (nonatomic, strong) NSError *error;

@property (nonatomic) unsigned long fileOffset;  // default is 1  (because of the "A" in createNewFile)

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSFileHandle *fileHandle;

@property (nonatomic, readonly) BOOL isNewFile;

//TODO: add support for it in methode writeAtEndOFFile
//@property (nonatomic) unsigned long long endOfFile;

// Either open the file or call "createNewFile" if file does not exists
- (instancetype)initWithURL:(NSURL *)aURL;

// subclasses have to override this methode and create a new file
// this class try to open it aferwards
- (void)createNewFile:(NSError **)errorPtr;

- (unsigned long long)endOfFile;

#pragma mark - CRUD Data

// CREATE

// READ

- (NSData *)read:(NSUInteger)length atPos:(unsigned long long)pos;

// UPDATE

- (void)write:(NSData *)data atPos:(unsigned long long)pos;

- (unsigned long long)writeAtEndOfFile:(NSData *)data;

// DELETE

@end
