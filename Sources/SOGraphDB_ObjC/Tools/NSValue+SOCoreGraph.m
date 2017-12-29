//
//  NSValue+SOCoreGraph.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 29.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "NSValue+SOCoreGraph.h"

@implementation NSValue (SOCoreGraph)

- (NSMutableData *)createMutableDataObject;
{
    NSUInteger bufferSize = 0;
    
    NSGetSizeAndAlignment([self objCType], &bufferSize, NULL);
    
    void* buffer = malloc(bufferSize);
    
    [self getValue:buffer];
    
    return [NSMutableData dataWithBytesNoCopy:buffer length:bufferSize];
}

- (NSData *)createDataObject;
{
    NSUInteger bufferSize = 0;
    
    NSGetSizeAndAlignment([self objCType], &bufferSize, NULL);
    
    void* buffer = malloc(bufferSize);
    
    [self getValue:buffer];
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize];
}

@end
