//
//  SONode.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOPropertyAccessElement.h"

@class SOProperty, SORelationship, SOGraphContext;

@interface SONode : SOPropertyAccessElement

#pragma mark - Relationship

#pragma mark OUT

// simples way to create a graph
// return a array of SONodes of the outRelationship
// TODO rename: relatedOUTNodes??
@property (nonatomic, readonly) NSArray *relatedNodes;

// related nodes follow a OUT relationship
- (SORelationship *)addRelatedNode:(SONode *)aNode;

@property (nonatomic, readonly) NSMutableArray *outRelationshipArray;

#pragma mark IN

- (SONode *)firstInNode;
- (SONode *)lastInNode;

@property (nonatomic, readonly) NSMutableArray *inRelationshipArray;

// cover OUTGOING relationships
//@property (nonatomic, readonly) NSDictionary *relationships;

#pragma mark - Property

// see SOPropertyAccess

//@property (nonatomic, readonly) NSDictionary *propertyDictionary;

@end

#pragma mark - Special Interface

@interface SONode (Internal)

// DON'T USE
// just available for testing
// 0 = there is not relationship for this node
@property (nonatomic) NSNumber *outRelationshipID;
@property (nonatomic) NSNumber *inRelationshipID;


// DON'T call this methodes, it will not delete all relevant data!
- (void)deleteOutRelationship:(SORelationship *)aRelationship;
- (void)deleteInRelationship:(SORelationship *)aRelationship;

@end
