//
//  SOGraphContex.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 18.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SONode.h"
#import "SORelationship.h"

@interface SOGraphContext : NSObject

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) NSURL *url;

#pragma mark -

- (instancetype)initWithURL:(NSURL *)aURL;

- (void)setCacheLimit:(NSInteger)limit;
- (void)setCacheDelegate:(id<NSCacheDelegate>)cacheDelegate;

#pragma mark - Transaction Handling

/**
- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

#pragma mark - CRUD Node

// No add method, node has no parameter they need just created
- (SONode *)createNode;

- (SONode *)readNode:(NSNumber *)aID;

- (void)updateNode:(SONode *)aObj;

- (void)deleteNode:(SONode *)aObj;

#pragma mark - CRUD Relationship (C = Add)

- (void)registerRelationship:(SORelationship *)aObj;

- (void)addRelationship:(SORelationship *)aObj;

- (SORelationship *)readRelationship:(NSNumber *)aID;

- (void)updateRelationship:(SORelationship *)aObj;

- (void)deleteRelationship:(SORelationship *)aObj;

#pragma mark - CRUD Property (C = Add)

- (void)registerProperty:(SOProperty *)aObj;

- (void)addProperty:(SOProperty *)aObj;

- (SOProperty *)readProperty:(NSNumber *)aID;

- (void)updateProperty:(SOProperty *)aObj;

- (void)deleteProperty:(SOProperty *)aObj;

#pragma mark - CRD Strings (C = Add)

- (NSNumber *)addString:(NSString *)text;

- (NSString *)readStringAtIndex:(NSNumber *)aIndex;

- (void)deleteStringAtIndex:(NSNumber *)aIndex;

@end
