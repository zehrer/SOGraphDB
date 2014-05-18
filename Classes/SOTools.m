//
//  SOTools.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOTools.h"

@implementation SOTools

+ (NSURL *)tempDirectory;
{
    return [NSURL fileURLWithPath:NSTemporaryDirectory()];
}



@end
