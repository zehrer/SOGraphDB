//
//  SOFileStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOObjectStore.h"

//
// This class handle data with a fix lenght
//
@interface SOManagedDataStore : SOObjectStore

@property (nonatomic, strong) NSData *header;
@property (nonatomic, strong) NSData *deleteHeader;
@property (nonatomic, strong) NSData *sampleData;

// record unused segment positions in the file
// The set include NSNumer object of the type "unsignedLongLongValue"
@property (nonatomic, strong, readonly) NSMutableSet *unusedDataSegments;

#pragma mark SOManagedDataStore

- (void)setupStore:(id<SOCoding>)aSampleObject;

#pragma mark - CRUD Data

- (unsigned long long)register;

#pragma mark - CRUD Objects  -> Register Read Update Delete

// A create (C) is split into a register and a write data (update)

// provide a ID for the object without storing it on disk.
- (NSNumber *)registerObject:(id<SOCoding>)aObj;

@end
