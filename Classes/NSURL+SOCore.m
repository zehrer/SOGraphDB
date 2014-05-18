//
//  NSURL+SOCore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 21.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "NSURL+SOCore.h"

@implementation NSURL (SOCore)

- (BOOL)isFileExisting;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self path]];
}

- (void)deleteFile;
{
    if ([self isFileExisting]) {
        NSError *aError = nil;
        
        [[NSFileManager defaultManager] removeItemAtURL:self error:&aError];
        
        if (aError) {
            NSLog(@"ERROR: delete %@",[self path]);
        }
    }
}

@end
