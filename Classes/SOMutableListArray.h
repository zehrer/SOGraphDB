//
//  SOMutableListArray.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 12.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOListElement.h"


// DON'T USE THIS CLASS!
//
// Test have shown, subclasses of NSMutableArray are not as simple as expected
// last problem: count need to be implemented
//
// This class does not support all methodes of NSArrayCreation!!
//
@interface SOMutableListArray : NSMutableArray

- (void)addListObject:(id<SOListElement>)aElement;

- (void)removeListObject:(id<SOListElement>)anObject;

//- (void)addObject:(id)anObject;

//- (void)removeObject:(id)anObject;

@end
