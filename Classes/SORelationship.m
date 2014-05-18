//
//  SORelationship.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "NSNumber+SOCoreGraph.h"

#import "SOGraphContext.h"

#import "SORelationship.h"

typedef struct {
    
    SOID relationshipTypeNodeID;    // 4   <- reference to a node
    SOID nextPropertyID;            // 4

    SOID startNodeID;               // 4
    SOID startNodePrevRelationID;   // 4
    SOID startNodeNextRelationID;   // 4

    SOID endNodeID;                 // 4
    SOID endNodePrevRelationID;     // 4
    SOID endNodeNextRelationID;     // 4
    
} RELATIONSHIP; //30

@interface SORelationship () {
    RELATIONSHIP relationship;
}

@end

@implementation SORelationship

#pragma mark - SOCoding

- (instancetype)initWithData:(NSData *)data;
{
    self = [super initWithData:data];
    {
        [data getBytes:&relationship length:sizeof(relationship)];
    }
    return self;
}

- (NSData *)encodeData;
{
    return [NSData dataWithBytes:&relationship length:sizeof(relationship)];
}

#pragma mark - SORelationship

- (instancetype)init
{
    self = [super init];
    if (self) {
        relationship.relationshipTypeNodeID = 0;
        relationship.nextPropertyID = 0;
        
        relationship.startNodeID = 0;
        relationship.startNodePrevRelationID = 0;
        relationship.startNodeNextRelationID = 0;
        
        relationship.endNodeID = 0;
        relationship.endNodePrevRelationID = 0;
        relationship.endNodeNextRelationID = 0;
    }
    return self;
}

- (instancetype)initWithStartNode:(SONode *)node;
{
    self = [self init];  // make sure all values are 0
    {
        relationship.startNodeID = [node.id ID];
    }
    return self;
}


#pragma mark - SOListElement

- (void)update;
{
    [[self context] updateRelationship:self];
}

- (void)delete;
{
    if (self.context) {
        SONode *startNode = [self.context readNode:self.startNodeID];
        SONode *endNode = [self.context readNode:self.endNodeID];
        
        [startNode deleteOutRelationship:self];
        [endNode deleteInRelationship:self];
        
        [[self context] deleteRelationship:self];
        
    }
}

- (void)setNextElementID:(NSNumber *)nextElementID;
{
    [self setStartNodeNextRelationID:nextElementID];
}

- (NSNumber *)nextElementID;
{
    return [self startNodeNextRelationID];
}

- (void)setPreviousElementID:(NSNumber *)previousElementID;
{
    [self setStartNodePreviousRelationID:previousElementID];
}

- (NSNumber *)previousElementID;
{
    return [self startNodePreviousRelationID];
}

#pragma mark StartNode

- (void)setStartNodeID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.startNodeID) {
        relationship.startNodeID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)startNodeID;
{
    return [NSNumber numberWithID:relationship.startNodeID];
}

- (void)setStartNodeNextRelationID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.startNodeNextRelationID) {
        relationship.startNodeNextRelationID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)startNodeNextRelationID;
{
    return [NSNumber numberWithID:relationship.startNodeNextRelationID];
}

- (void)setStartNodePreviousRelationID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.startNodePrevRelationID) {
        relationship.startNodePrevRelationID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)startNodePreviousRelationID;
{
    return [NSNumber numberWithID:relationship.startNodePrevRelationID];
}

#pragma mark EndNode

- (void)setEndNodeID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.endNodeID) {
        relationship.endNodeID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)endNodeID;
{
    return [NSNumber numberWithID:relationship.endNodeID];
}

- (void)setEndNodeNextRelationID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.endNodeNextRelationID) {
        relationship.endNodeNextRelationID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)endNodeNextRelationID;
{
    return [NSNumber numberWithID:relationship.endNodeNextRelationID];
}

- (void)setEndNodePreviousRelationID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.endNodePrevRelationID) {
        relationship.endNodePrevRelationID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)endNodePreviousRelationID;
{
    return [NSNumber numberWithID:relationship.endNodePrevRelationID];
}


#pragma mark - Property

- (void)setPropertyID:(NSNumber *)aID;
{
    SOID numID = [aID ID];
    
    if (numID != relationship.nextPropertyID) {
        relationship.nextPropertyID = numID;
        self.isDirty = YES;
    }
}

- (NSNumber *)propertyID;
{
    return [NSNumber numberWithID:relationship.nextPropertyID];
}

@end

/**
 - (BOOL)isStartNodeRelationID:(NSNumber *)aID;
 {
 SOID nodeID = aID.unsignedIntValue;
 
 if (nodeID == relationship.startNode) {
 return YES;
 }
 
 return NO;
 }
 
 - (BOOL)isEndNodeRelationID:(NSNumber *)aID;
 {
 SOID nodeID = aID.unsignedIntValue;
 
 if (nodeID == relationship.endNode) {
 return YES;
 }
 
 return NO;
 }
 
 
 
 - (SOID)nextRelationIDByNode:(NSNumber *)aID;
 {
 SOID nodeID = aID.unsignedIntValue;
 
 if (nodeID == relationship.startNode) {
 return relationship.startNodeNextRelationID;
 }
 
 if (nodeID == relationship.endNode) {
 return relationship.endNodeNextRelationID;
 }
 
 return 0;
 }
 
 */
