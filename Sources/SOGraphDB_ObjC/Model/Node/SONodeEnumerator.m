//
//  SONodeEnumerator.m
//  SOGraphDB
//
//  Created by Stephan Zehrer on 28.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "SOGraphContext.h"
#import "SORelationship.h"

#import "SONodeEnumerator.h"

@implementation SONodeEnumerator

- (instancetype)initWithNode:(SONode *)aNode;
{
    self = [super init];
    if (self) {
        _context = aNode.context;
        self.nextRelationshipID = [[aNode outRelationshipID] ID];
    }
    return self;
}

- (id)nextObject;
{
    SORelationship *relationship;
    
    if (self.nextRelationshipID > 0) {
        relationship = [self.context readRelationship:[NSNumber numberWithID:self.nextRelationshipID]];
        
        self.nextRelationshipID = [[relationship startNodeNextRelationID] ID];
        
        return [self.context readNode:relationship.endNodeID];
    }

    return nil;
}

@end
