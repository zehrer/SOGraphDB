//
//  SONodeStore.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 19.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SONode.h"

#import "SONodeStore.h"

@implementation SONodeStore

- (instancetype)initWithURL:(NSURL *)url;
{
    self = [super initWithURL:url];
    if (self) {
        [self setupStore:[[SONode alloc] init]];
    }
    return self;
}

@end
