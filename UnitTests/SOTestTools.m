//
//  SOTestTools.m
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOCoreGraph/SONode.h>

#import "SOTestTools.h"

@interface SOTestTools ()

@property (nonatomic,strong) SONode *keyNode;

@end

@implementation SOTestTools

const NSInteger NUM_LINKED_NODES = 2;

- (id)initWithContext:(SOGraphContext *)context;
{
    self = [super init];
    if (self) {
        self.context = context;
        
        self.keyNode =  [context readNode:@1];
    }
    return self;
}

- (NSArray *)addIncreasingLinksToNodes:(NSArray *)nodes;
{
	NSMutableArray *allLinks = [NSMutableArray arrayWithCapacity:[nodes count] * NUM_LINKED_NODES];
	
	for (SONode *node in nodes)
	{
		NSInteger i;
		for (i = 0; i < NUM_LINKED_NODES; i++)
		{
			SONode *link = [self.context createNode];
			[allLinks addObject:link];
            [node addRelatedNode:link];
            
            if (self.keyNode) {
                [node setLongValue:[[node id] longValue]forKey:self.keyNode];
            }
            
		}
	}
	
	return allLinks;
}

+ (NSArray *)addDecreasingLinksToNodes:(NSArray *)nodes withContext:(SOGraphContext *)context;
{
	NSMutableArray *allLinks = [NSMutableArray arrayWithCapacity:[nodes count] / NUM_LINKED_NODES];
	
	NSInteger i = 0;
	for (i = 0; i < [nodes count]; i += NUM_LINKED_NODES)
	{
		SONode *link = [context createNode];
		[allLinks addObject:link];

		NSInteger j;
		for (j = i; j < i + NUM_LINKED_NODES; j++)
		{
            SONode *node = [nodes objectAtIndex:j];
            [node addRelatedNode:link];
		}
	}
	
	return allLinks;
}

- (SONode *)createNodeGraphWithDepth:(NSUInteger)graphDepth;
{
    SONode *head = [self.context createNode];
    
    NSArray *nodeArray = [NSArray arrayWithObject:head];
    
    NSInteger i;
    self.createdNodes = 1;
    
    for (i = 0; i < graphDepth; i++)
    {
        nodeArray = [self addIncreasingLinksToNodes:nodeArray];
        self.createdNodes += [nodeArray count];
    }
    
    /**

    for (i = 0; i < graphDepth; i++)
    {
        nodeArray = [SOTestTools addDecreasingLinksToNodes:nodeArray withContext:self.context];
        totalNodeCount += [nodeArray count];
    }
     
     */

    
    NSLog(@"Created %ld nodes", self.createdNodes);
    
    return head;
}

+ (NSInteger)traverseGraphFromNode2:(SONode *)startingNode;
{
	NSDate *startDate = [NSDate date];
	
	NSMutableSet *visitedNodes = [NSMutableSet setWithObject:startingNode];
	NSMutableArray *queue = [NSMutableArray arrayWithObject:startingNode];
	NSInteger nodeCount = 0;
	
	while ([queue count] > 0)
	{
        SONode *node = [queue lastObject];
        NSArray *nodes = [node relatedNodes];
        
		for (SONode *newNode in nodes)
		{
			if (![visitedNodes containsObject:newNode])
			{
				[visitedNodes addObject:newNode];
				[queue insertObject:newNode atIndex:0];
                //NSLog(@"Node :%@",newNode.id);
                //nodeCount++;
			}
		}
        
		[queue removeLastObject];
		nodeCount++;
	}
	
	NSDate *endDate = [NSDate date];
	NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    
	NSLog(@"2: Visited %ld nodes in %f seconds", nodeCount, interval);
    
    return nodeCount;
}

- (void)recursivelyTraverse:(SONode *)node;
{
	NSArray *nodes = [node relatedNodes];
	for (SONode *newNode in nodes)
	{
		if (![recursiveSet containsObject:newNode])
		{
			[recursiveSet addObject:newNode];
			[self recursivelyTraverse:newNode];
		}
	}
	
	self.recursiveNodeCount++;
}

- (void)traverseGraphFromNode6:(SONode *)startingNode;
{
	NSDate *startDate = [NSDate date];
	
	recursiveSet = [NSMutableSet setWithObject:startingNode];
	
	[self recursivelyTraverse:startingNode];
	
	NSDate *endDate = [NSDate date];
	NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    
	NSLog(@"6: Visited %ld nodes in %f seconds", self.recursiveNodeCount, interval);
}


@end
