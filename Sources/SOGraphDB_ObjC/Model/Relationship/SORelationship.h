//
//  SORelationship.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOGraphDB/SOListElement.h>
#import <SOGraphDB/SOPropertyAccessElement.h>

@class SONode;
@class SOGraphContext;

@interface SORelationship : SOPropertyAccessElement <SOListElement,SOCoding>

#pragma mark - SORelationship

- (instancetype)initWithStartNode:(SONode *)node;

// SOListElement manage the start node relationship

@property (nonatomic, readonly) SONode *startNode;
@property (nonatomic, readonly) SONode *endNode;


@end

@interface SORelationship (Internal)

// DON'T USE
// just available for testing
// 0 = there is not relationship for this node
@property (nonatomic) NSNumber *startNodeID;
@property (nonatomic) NSNumber *startNodeNextRelationID;
@property (nonatomic) NSNumber *startNodePreviousRelationID;

@property (nonatomic) NSNumber *endNodeID;
@property (nonatomic) NSNumber *endNodeNextRelationID;
@property (nonatomic) NSNumber *endNodePreviousRelationID;

@end
