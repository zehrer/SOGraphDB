//
//  SOElementList.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 11.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//
#import "SOGraphContext.h"
#import "SOListElement.h"

#import "SOElementList.h"


@interface SOElementList ()

@property (nonatomic, strong) NSMutableArray *elementArray;

@end

@implementation SOElementList


- (void)addToElementArray:(id<SOListElement>)element;
{
    [[self elementArray] addObject:element];
}

- (void)removeFromElementArray:(id<SOListElement>)element;
{
    [[self elementArray] removeObject:element];
}

#pragma mark SOPropertyAccess support

- (void)addElement:(id<SOListElement>)element;
{
    // create the ID of this new property without a CONTEXT WRITE
    [self.owner registerElement:element];                       // <-- special
    
    // append after last element
    id<SOListElement> lastElement = [[self elementArray] lastObject];
    
    if (lastElement) {
        // it seems this element has already one or more properties
        // add property to the last one
        element.previousElementID = lastElement.id;
        lastElement.nextElementID = element.id;
        
        // CONTEXT WRITE
        // updated of the LAST relationship is only required if
        // the is was extended
        [lastElement update];
        
    } else {
        // It seems this is the frist relationship
        
        // add relationship to the element  (e.g. Node -> Property)
        [self.owner setElementID:element.id];
        
        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self.owner update];
    }
    
    // CONTEXT WRTIE
    [element update];
    
    // add property to internal array and maps
    [self addToElementArray:element];
}

- (void)deleteElement:(id<SOListElement>)aElement;
{
    id<SOListElement> previousElement = nil;
    id<SOListElement> nextElement = nil;
    
    NSNumber *nextElementID = [aElement nextElementID];
    NSNumber *previousElementID = [aElement previousElementID];
    
    if (nextElementID) {
        nextElement = [self.owner readElement:nextElementID];
        
        [nextElement setPreviousElementID:previousElementID];
        
        // CONTEXT WRITE
        [nextElement update];
    }
    
    if (previousElementID) {
        previousElement = [self.owner readElement:previousElementID];
        
        [previousElement setNextElementID:nextElementID];
        
        // CONTEXT WRITE
        [previousElement update];
        
    } else {
        // seems this is the first relationship in the chain
        [self.owner setElementID:nextElementID];
        
        
        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self.owner update];
    }
    
    // CONTEXT WRITE
    [aElement delete];
    
    // update property to internal array and maps
    [self removeFromElementArray:aElement];
}

@end
