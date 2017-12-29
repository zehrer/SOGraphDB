//
//  SOMutableListArray.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 12.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOListElement.h"

#import "SOMutableListArray.h"

@implementation SOMutableListArray


+ (SOMutableListArray *)array;
{
    return [[SOMutableListArray alloc] init];
}

- (NSUInteger)count;
{
    return [super count];
}

- (void)addListObject:(id<SOListElement>)aElement;
{
    if ([aElement conformsToProtocol:@protocol(SOListElement)]) {
        
        // append after last element
        id<SOListElement> lastElement = [self lastObject];
        
        if (lastElement) {
            // it seems this element has already one or more properties
            // add property to the last one
            aElement.previousElementID = lastElement.id;
            lastElement.nextElementID = aElement.id;
            
            // CONTEXT WRITE
            // updated of the LAST relationship is only required if
            // the is was extended
            [lastElement update];
        }
        
        // link between owner and  the first list element is not maintaine here
        
        // CONTEXT WRTIE
        [aElement update];

    }
    
    [self addObject:aElement];
}

- (void)removeListObject:(id<SOListElement>)aElement;
{
    
    if ([aElement conformsToProtocol:@protocol(SOListElement)]) {
        
        id<SOListElement> previousElement = nil;
        id<SOListElement> nextElement = nil;
        
        NSNumber *nextElementID = [aElement nextElementID];
        NSNumber *previousElementID = [aElement previousElementID];
        
        NSUInteger index = [self indexOfObject:aElement];
        
        if (nextElementID) {
            // not last element
            
            nextElement = [self objectAtIndex:index + 1];
            
            [nextElement setPreviousElementID:previousElementID];
            
            // CONTEXT WRITE
            [nextElement update];
        }
        
        if (previousElementID) {
            // not first element
            previousElement = [self objectAtIndex:index -1];
            
            [previousElement setNextElementID:nextElementID];
            
            // CONTEXT WRITE
            [previousElement update];
            
        }
        
        // link between owner and  the first list element is not maintaine here
        
        // CONTEXT WRITE
        [aElement delete];
        
    }
    
    [self removeObject:aElement];
}


/**
 else {
 // It seems this is the frist relationship
 
 // add relationship to the element  (e.g. Node -> Property)
 [self.owner setElementID:element.id];
 
 // CONTEXT WRITE
 // update of self is only required if the id was set
 [self.owner update];
 }
 */

@end
