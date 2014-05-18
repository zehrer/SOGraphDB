//
//  NSData+SOCoreGraph.m
//  SOGraphDB
//
//  Created by Stephan Zehrer on 21.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "NSData+SOCoreGraph.h"

@implementation NSData (SOCoreGraph)

- (NSArray *)subdataWithMaxLength:(NSUInteger)maxLength;
{
    NSMutableArray *result = [NSMutableArray array];
    
    if (self.length > maxLength) {
        // split data
        
        int pos = 0;
        
        while (pos + self.length > maxLength) {
            NSRange aRange = NSMakeRange(pos,maxLength);
            [result addObject:[self subdataWithRange:aRange]];
            pos += maxLength;
        }
        
    } else {
        [result addObject:self];
    }
    
    return result;
}

// 0123456789012345678901234567890

@end
