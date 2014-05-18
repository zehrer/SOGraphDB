//
//  SOGraphElement.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOCoding.h"

@class SOGraphContext;

@interface SOGraphElement : NSObject  <SOCoding>

// a node can only belong to one context
// don't edit this property, it is managed by the SOGraphContext itself.
@property (nonatomic, weak) SOGraphContext *context;

// Subclasses have to override this methode to initiate a self update
- (void)update;


// TODO: enabled delete too?
//- (void)delete;

@end
