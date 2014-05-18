//
//  SOStringIndexStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOObjectStore.h"

#import "SOTextIndexObject.h"

// This class manage string index's for the SOStringStore.
// TSOIndextObject's
//  - NSRange -> provide the specific pos and length of the string to read
//  - id the index number of the string
//
// this class will return only index object which are used
//
// This methode don't store the string !!!
@interface SOTextIndexStore : SOObjectStore

#pragma mark - CRUD

// This method try to find a free space in the stringStore.
// @return nil if it did not find a space in the stringStore
- (SOTextIndexObject *)addStringData:(SOStringData *)stringData;

// This method add a new indexObject to the indexStore.
// This is usually called to add a String at the end of the SOStringStore
// This method return nil of the object is not new
- (SOTextIndexObject *)addStringIndex:(SOTextIndexObject *)indexObject;

// read stringIndex of the ID
// it return nil if the specified ID is not in use at the moment
- (SOTextIndexObject *)readStringIndex:(NSNumber *)aID;

// update the string at the specified index & stringData (in the indexObject)
// depended of the size changes it may move the string to a new possition
// if the id was not used it return nil
- (BOOL)updateStringIndex:(SOTextIndexObject *)indexObject withStringData:(SOStringData *)aStringData;

// mark the id as deleted
// this has no impact on the string store
- (void)deleteStringIndex:(NSNumber *)aID;



@end
