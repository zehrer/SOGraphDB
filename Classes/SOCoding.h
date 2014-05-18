//
//  SOCoding.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 18.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SOCoding <NSObject>

// define the possition of the node in the node store
// return nil of not in the store
// don't set this @property, it is manged by the store
@property (nonatomic) NSNumber *id;

// mark if the was updated on disk.
@property (nonatomic) BOOL isDirty;

@required

- (instancetype)initWithData:(NSData *)data;

- (NSData *)encodeData;

@optional

- (void)decodeData:(NSFileHandle *)fileHandle;

@end
