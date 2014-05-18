//
//  SOStringStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOFileStore.h"

// This class persist strings of differen lengths quite efficient.
// To save memory it uses different encodings for each string
//  - NSUTF8StringEncoding (if possible)
//  - NSUnicodeStringEncoding (as fallback)
// The intension of this store is to store strings in a context of a data for example.
// It does not store formated stings.
// This store maintain two files:
//  - A text file with all strings
//  - A index file of each string in the text file
//
// It is not possible to re-create the index file!
@interface SOTextStore : SOFileStore

@property (nonatomic,readonly) NSURL *indexStoreURL;

#pragma mark - CRUD

// This methode add a NEW string to the store
- (NSNumber *)addString:(NSString *)text;

// This methode read the string data from the store
- (NSString *)readStringAtIndex:(NSNumber *)aIndex;

// This method update string data in the store
// it does not include content compare
// it don't store a cached version of the string
- (void)updateString:(NSString *)text atIndex:(NSNumber *)aIndex;

// Marke the string as deleted
// It does not override the data in the store
- (void)deleteStringAtIndex:(NSNumber *)aIndex;

@end
