//
//  SOGraphElement.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOGraphElement.h"

@implementation SOGraphElement

@synthesize id;
@synthesize isDirty;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.id = nil;
        self.isDirty = YES;  //create new one
    }
    return self;
}

#pragma mark - SOCoding

- (instancetype)initWithData:(NSData *)data;
{
    self = [super init];
    {
        self.id = nil;
        self.isDirty = NO;  // expected to created direcly from the data and therefore not diry
    }
    return self;
}

- (NSData *)encodeData;
{
    return nil;
}

- (void)update;
{
    NSLog(@"ERROR: override this methode");
}

@end
