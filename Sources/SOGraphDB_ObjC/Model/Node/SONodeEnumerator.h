//
//  SONodeEnumerator.h
//  SOGraphDB
//
//  Created by Stephan Zehrer on 28.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

@class SOGraphContext;
@class SONode;

#import "NSNumber+SOCoreGraph.h"

@interface SONodeEnumerator : NSEnumerator

@property (nonatomic, weak, readonly) SOGraphContext *context;

@property SOID nextRelationshipID;


- (instancetype)initWithNode:(SONode *)aNode;

// - (id)nextObject;

@end
