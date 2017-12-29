//
//  NSData+SOCoreGraph.h
//  SOGraphDB
//
//  Created by Stephan Zehrer on 21.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SOCoreGraph)

- (NSArray *)subdataWithMaxLength:(NSUInteger)maxLength;

- (NSData *)extendSize:(NSUInteger)maxLength;

- (unsigned long)crc32Hash;

@end
