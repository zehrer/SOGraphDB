//
//  SOStringStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This protocol provide access to a string store which fulfil the follwing requirements:
 *  - Eeach unique string is stored only once
 *  - Each string is associated to an permanent index
 *  - Strings a cases sensitive
 *  - withespaces are allowed
 *  - methode calls are atomic and lead to directly to persistent
 */
@protocol SOStringStore <NSObject>

#pragma mark - CRUD

@required

// This methode either add a new string to the store or return the ID if the existing one
- (NSNumber *)addString:(NSString *)text;

// This methode return the string at the specified indexs
- (NSString *)readStringAtIndex:(NSNumber *)aIndex;

@optional

// Delete a string in the store and deallocate the related index
- (void)deleteStringAtIndex:(NSNumber *)aIndex;

// TODO
// This method update string data in the store
// it does not include content compare
// it don't store a cached version of the string
//- (NSNumber *))updateString:(NSString *)text atIndex:(NSNumber *)aIndex;

@end
