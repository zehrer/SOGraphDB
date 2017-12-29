//
//  NSNumber+SOCoreGraph.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//


#import "NSNumber+SOCoreGraph.h"

@implementation NSNumber (SOCoreGraph)

+ (instancetype)numberWithID:(SOID)aID;
{
    return [NSNumber numberWithUnsignedInt:aID];
}

- (SOID)ID;
{
    return [self unsignedIntValue];
}

- (NSData *)encode;
{
    unsigned int value = [self unsignedIntValue];
    
    return [NSData dataWithBytes:&value length:sizeof(value)];
}

@end
