//
//  SOTestTools.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOGraphDB/SOGraphDB.h>

@interface SOTestTools : NSObject {
    NSMutableSet *recursiveSet;
}

@property (nonatomic, strong) SOGraphContext *context;

@property (nonatomic) NSInteger createdNodes;
@property (nonatomic) NSInteger recursiveNodeCount;

- (id)initWithContext:(SOGraphContext *)context;

- (SONode *)createNodeGraphWithDepth:(NSUInteger)graphDepth;

- (void)traverseGraphFromNode6:(SONode *)startingNode;

+ (NSInteger)traverseGraphFromNode2:(SONode *)startingNode;


@end
