//
//  SOElementList.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 11.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOListElement.h"

@class SOGraphContext;

@protocol SOListOwner <NSObject>

@property (nonatomic) NSNumber *elementID;

- (void)update;
//- (void)delete;

- (void)registerElement:(id<SOListElement>)element;
- (id<SOListElement>)readElement:(NSNumber *)aID;

@end

@interface SOElementList : NSObject

@property (nonatomic, weak) id<SOListOwner> owner;

- (void)addElement:(id<SOListElement>)element;

- (void)addToElementArray:(id<SOListElement>)element;

@end
