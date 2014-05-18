//
//  SONode.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOGraphContext.h"
#import "NSNumber+SOCoreGraph.h"

#import "SONode.h"

typedef struct {
    SOID nextPropertyID; // 4
    SOID nextOutRelationshipID;  // 4
    SOID nextInRelationshipID;  // 4
} NODE;
    
    
@interface SONode () {
    NODE node;
}

@property (nonatomic, strong) NSMutableArray *inRelationshipArray;
@property (nonatomic, strong) NSMutableArray *outRelationshipArray;

@end

@implementation SONode

- (instancetype)init
{
    self = [super init];
    if (self) {
        node.nextOutRelationshipID = 0;
        node.nextInRelationshipID = 0;
        node.nextPropertyID = 0;
    }
    return self;
}

#pragma mark - SOCoding

- (instancetype)initWithData:(NSData *)data;
{
    self = [super initWithData:data];
    {
        [data getBytes:&node length:sizeof(node)];
    }
    return self;
}

- (NSData *)encodeData;
{
    return [NSData dataWithBytes:&node length:sizeof(node)];
}

#pragma mark - Relationship

#pragma mark OUT


- (void)deleteOutRelationship:(SORelationship *)aRelationship;
{
    SORelationship *previousRelationship = nil;
    SORelationship *nextRelationship = nil;
    
    NSNumber *nextRelationshipID = [aRelationship startNodeNextRelationID];
    NSNumber *previousRelationshipID = [aRelationship startNodePreviousRelationID];
    
    if (nextRelationshipID) {
        nextRelationship = [[self context] readRelationship:nextRelationshipID];
        
        [nextRelationship setStartNodePreviousRelationID:previousRelationshipID];
        
        // CONTEXT WRITE
        [[self context] updateRelationship:nextRelationship];
    }
    
    if (previousRelationshipID) {
        previousRelationship = [[self context] readRelationship:previousRelationshipID];
        
        [previousRelationship setStartNodeNextRelationID:nextRelationshipID];
        
        // CONTEXT WRITE
         [[self context] updateRelationship:previousRelationship];
        
    } else {
        // seems this is the first relationship in the chain
        [self setOutRelationshipID:nextRelationshipID];
        
        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self update];
    }
    
    [self.outRelationshipArray removeObject:aRelationship];
}

- (void)setOutRelationshipID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != node.nextOutRelationshipID) {
        node.nextOutRelationshipID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)outRelationshipID;
{
    return [NSNumber numberWithInteger:node.nextOutRelationshipID];
}

- (NSMutableArray *)outRelationshipArray;
{
    if (_outRelationshipArray == nil) {
        _outRelationshipArray = [NSMutableArray array];
        
        // read data
        SORelationship *relationship = nil;
        SOID nextRelationshipID = node.nextOutRelationshipID;
        
        while (nextRelationshipID > 0) {
            
            relationship = [self.context readRelationship:[NSNumber numberWithID:nextRelationshipID]] ;
            
            [_outRelationshipArray addObject:relationship];
            
            nextRelationshipID = [[relationship startNodeNextRelationID] ID];
        }
    }
    
    return _outRelationshipArray;
}

- (NSArray *)relatedNodes;
{
    NSMutableArray *result = [NSMutableArray array];
    
    if (self.context) {
        // reading is only possible if this node is in a context
        
        // UseCase: new (in context) -> isDiry = false && context != nil  (if the context store directly)
        // Usecase: updated (in context) -> isDiry =
        
        NSArray *outArray = self.outRelationshipArray;
        
        for (SORelationship *relationship in outArray) {
            SONode *aNode = [self.context readNode:[relationship endNodeID]];
            [result addObject:aNode];
        }
    }
    
    return result;
}


// Create a new relation add it to the start node (this node) and the end node
// This methode update
//   - the new relationship
//   - (optional) the start node (itself) -> rel was appended directly
//   - (optional) the start node lastRelationship -> the rel was appended
//   - (optional) the end node - by calling insertInRelationship
//   - (optional) the end node lastRelationship - by calling insertInRelationship
- (SORelationship *)addOutNodeRelationship:(SONode *)endNode;
{
    if ([self context]) {
        // create an new realationship with a link to the this node
        SORelationship *relationship = [[SORelationship alloc] initWithStartNode:self];

         // create the ID of this new relationship without a CONTEXT WRITE
        // TODO self registering??
        [[self context] registerRelationship:relationship];
        
        [endNode insertInRelationship:relationship];
        
        NSMutableArray *outRelationships = [self outRelationshipArray];
        
        SORelationship *lastRelationship = [outRelationships lastObject];
        
        if (lastRelationship) {
            // it seems this node has already one or more relationships
            // add relationship to the last one
            relationship.startNodePreviousRelationID = lastRelationship.id;
            lastRelationship.startNodeNextRelationID = relationship.id;
            
            // updated of the LAST relationship is only required if
            // the is was extended
// CONTEXT WRITE
            [[self context] updateRelationship:lastRelationship];
            
        } else {
            // it seems this is the frist relationship
            // add relationship to the node
            [self setOutRelationshipID:relationship.id];
            
// CONTEXT WRITE
            // update of self is only required if the id was set
            [self update];
        }

// CONTEXT WRITE
        [[self context] updateRelationship:relationship];
        
        [outRelationships addObject:relationship];
        
        return relationship;
    }
    
    return nil;
}

- (SORelationship *)addRelatedNode:(SONode *)aNode;
{
    return [self addOutNodeRelationship:aNode];
}

#pragma mark IN

- (void)deleteInRelationship:(SORelationship *)aRelationship;
{
    SORelationship *previousRelationship = nil;
    SORelationship *nextRelationship = nil;
    
    NSNumber *nextRelationshipID = [aRelationship endNodeNextRelationID];
    NSNumber *previousRelationshipID = [aRelationship endNodePreviousRelationID];
    
    if (nextRelationshipID) {
        nextRelationship = [[self context] readRelationship:nextRelationshipID];
        
        [nextRelationship setEndNodePreviousRelationID:previousRelationshipID];
        
        // CONTEXT WRITE
        [[self context] updateRelationship:nextRelationship];
    }
    
    if (previousRelationshipID) {
        previousRelationship = [[self context] readRelationship:previousRelationshipID];
        
        [previousRelationship setEndNodeNextRelationID:nextRelationshipID];
        
        // CONTEXT WRITE
        [[self context] updateRelationship:previousRelationship];
        
    } else {
        // seems this is the first relationship in the chain
        [self setInRelationshipID:nextRelationshipID];
        
        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self update];
    }
    
    [self.inRelationshipArray removeObject:aRelationship];
}


- (void)setInRelationshipID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != node.nextInRelationshipID) {
        node.nextInRelationshipID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)inRelationshipID;
{
    return [NSNumber numberWithInteger:node.nextInRelationshipID];
}


- (NSMutableArray *)inRelationshipArray;
{
    if (_inRelationshipArray == nil) {
        _inRelationshipArray = [NSMutableArray array];
        
        // read data
        SORelationship *relationship = nil;
        SOID nextRelationshipID = node.nextInRelationshipID;
        
        while (nextRelationshipID > 0) {
            
            relationship = [self.context readRelationship:[NSNumber numberWithID:nextRelationshipID]] ;
            
            [_inRelationshipArray addObject:relationship];
            
            nextRelationshipID = [[relationship endNodeNextRelationID] ID];
        }
    }
    
    return _inRelationshipArray;
}

- (SONode *)firstInNode;
{
    if (self.context) {
        
        SORelationship *relationship = [self.context readRelationship:[self inRelationshipID]];
        
        return [self.context readNode:[relationship startNodeID]];
    }
    return nil;
}

- (SONode *)lastInNode;
{
    if (self.context) {
        
        NSArray *inRelationshipArray = self.inRelationshipArray;
        SORelationship *relationship = [inRelationshipArray lastObject];
        
        return [self.context readNode:[relationship startNodeID]];
    }
    
    return nil;
}



// Update the ID's the new specified IN relationship
// This method update
//  - optional : the end node (itself) -> rel was appended directly
//  - optional : the lastRelationship if the rel was appended
- (void)insertInRelationship:(SORelationship *)relationship;
{
    // view from then endNode
    relationship.endNodeID = self.id;
    
    NSMutableArray *inRelationships = [self inRelationshipArray];
    
    SORelationship *lastRelationship = [inRelationships lastObject];
    
    if (lastRelationship) {
        // it seems this node has already one or more relationships
        // add relationship to the last one
        relationship.endNodePreviousRelationID = lastRelationship.id;
        lastRelationship.endNodeNextRelationID = relationship.id;
        
        [[self context] updateRelationship:lastRelationship];
    } else {
        // it seems this is the frist relationship
        // add relationship to the node
        [self setInRelationshipID:relationship.id];
        
// CONTEXT
        [self update];
    }
    
    [inRelationships addObject:relationship];
}


// CONTEXT
- (void)update;
{
    [[self context] updateNode:self];
}

#pragma mark - Property

- (void)setPropertyID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != node.nextPropertyID) {
        node.nextPropertyID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)propertyID;
{
    return [NSNumber numberWithID:node.nextPropertyID];
}

/**
#pragma mark - NSCoding  -> move to category 

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        //node.nextRelationshipID = [coder decodeInt32ForKey:@"1"];
        //node.nextPropertyID = [coder decodeInt32ForKey:@"2"];
        self.id = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
    //[encoder encodeInt32:node.nextRelationshipID forKey:@"1"];
    //[encoder encodeInt32:node.nextPropertyID forKey:@"2"];
}
*/

@end
