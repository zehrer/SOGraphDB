//
//  SOPropertyAccessElement.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 27.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOGraphContext.h"

#import "SONode.h"

#import "SOPropertyAccessElement.h"

#import "NSNumber+SOCoreGraph.h"

@interface SOPropertyAccessElement ()

@property (nonatomic, strong) NSMutableArray *propertyArray;
@property (nonatomic, strong) NSMapTable *propertyMap;

@end

@implementation SOPropertyAccessElement


#pragma mark General

- (id)deleteValueforKey:(SONode *)keyNode;
{
    if ([self context]) {
        
        SOProperty *property = [self propertyForKey:keyNode];
        
        if (property) {
            
            id data = property.data;
            
            [self deleteProperty:property];
            
            return data;
        }
        
    }
    return nil;
}

#pragma mark - SOPropertyAccess

#pragma mark Long

- (void)setLongValue:(long)aValue forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        [property setLongValue:aValue];
        
        [self.context updateProperty:property];
    }
}

- (long)longValueForKey:(SONode *)keyNode;
{
    SOProperty *property = [self propertyForKey:keyNode];
    
    if (property) {
        return property.longValue;
    }
    
    [self raiseError];
    return 0;
}


#pragma mark Unsigned Long

- (void)setUnsignedLongValue:(unsigned long)aValue forKey:(SONode *)keyNode;
{
    if ([self context]) {
        
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        [property setUnsignedLongValue:aValue];
        
        [self.context updateProperty:property];
    }

}


- (unsigned long)unsignedLongValueForKey:(SONode *)keyNode;
{
    SOProperty *property = [self propertyForKey:keyNode];
    
    if (property) {
        return property.unsignedLongValue;
    }
    
    [self raiseError];
    return 0;
}

#pragma mark Double

- (void)setDoubleValue:(double)aValue forKey:(SONode *)keyNode;
{
    if ([self context]) {
        
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        [property setDoubleValue:aValue];
        
        [self.context updateProperty:property];
    }
}

- (double)doubleValueForKey:(SONode *)keyNode;
{
    SOProperty *property = [self propertyForKey:keyNode];
    
    if (property) {
        return property.doubleValue;
    }
    
    [self raiseError];
    return 0.0;
}

#pragma mark NSString

- (void)setStringValue:(NSString *)text forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        [property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSString *)stringValueForKey:(SONode *)keyNode;
{
    SOProperty *property = [self propertyForKey:keyNode];
    
    if (property) {
        return property.stringValue;
    }

    return nil;
}

#pragma mark NSDate

- (void)setDateValue:(NSDate *)aNumber forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        //[property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSDate *)dateValueForKey:(SONode *)keyNode;
{
    return nil;
}

#pragma mark NSURL

- (void)setURLValue:(NSURL *)aNumber forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        //[property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSURL *)urlValueForKey:(SONode *)keyNode;
{
    return nil;
}

#pragma mark NSUUID

- (void)setUUIDValue:(NSUUID *)aNumber forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        //[property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSUUID *)uuidValueForKey:(SONode *)keyNode;
{
    return nil;
}

#pragma mark NSDecimalNumber

- (void)setDecimalValue:(NSDecimalNumber *)aNumber forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        //[property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSDecimalNumber *)decimalValueForKey:(SONode *)keyNode;
{
    return nil;
}

#pragma mark NSNumber

- (void)setNumberValue:(NSNumber *)aNumber forKey:(SONode *)keyNode;
{
    if ([self context]) {
        SOProperty *property = [self ensurePropertyforKey:keyNode];
        
        //[property setStringValue:text];
        
        [self.context updateProperty:property];
    }
}

- (NSNumber *)numberValueForKey:(SONode *)keyNode;
{
    return nil;
}

#pragma mark - SOPropertyAccessElement

#pragma mark propertyMap & propertyArray


// DONE -> dictionary in SWIFT
- (NSMapTable *)propertyMap;
{
    if ((_propertyMap == nil) && [self context]) {
        _propertyMap = [NSMapTable strongToStrongObjectsMapTable];
        [self readPropertyData];
    }
    
    return _propertyMap;
}

// DONE -> properties
- (NSMutableArray *)propertyArray;
{
    if ((_propertyArray == nil) && [self context]) {
        _propertyArray = [NSMutableArray array];
        [self readPropertyData];
    }
    
    return _propertyArray;
}

// DONE -> new name addToPropertyCollections
- (void)addToPropertyArray:(SOProperty *)property;
{
    [[self propertyMap] setObject:property forKey:property.keyNodeID];
    [[self propertyArray] addObject:property];
}

// DONE -> new name removedFromPropertyCollections
- (void)removeFromPropertyArray:(SOProperty *)property;
{
    [[self propertyMap] removeObjectForKey:property.keyNodeID];
    [[self propertyArray] removeObject:property];
}

// DONE
- (void)readPropertyData;
{
    // read data
    SOProperty *property = nil;
    SOID nextPropertyID = [[self propertyID] ID];
    
    while (nextPropertyID > 0) {
        
        property = [self.context readProperty:[NSNumber numberWithID:nextPropertyID]];
        
        [self addToPropertyArray:property];
        
        nextPropertyID = [[property nextPropertyID] ID];
    }
}

#pragma mark SOPropertyAccess support

// DONE (but only copyied)
- (void)raiseError;
{
//#warning writing exception key
    [NSException raise:NSInvalidArchiveOperationException format:@"Property for key not found"];
}

// DONE
- (SOProperty *)propertyForKey:(SONode *)keyNode;
{
    // context test is in "propertyMap"
    return [[self propertyMap] objectForKey:keyNode.id];
}

// DONE
- (SOProperty *)ensurePropertyforKey:(SONode *)keyNode;
{
    SOProperty *property = [self propertyForKey:keyNode];
        
    if (property == nil) {
        property = [self createPropertyForKeyNode:keyNode];
    }
    
    return property;
}

// Create a new property and add it to the element
// This methode update
//   - the new property (twice, 1. create 2. update)
//   - (optional) the lastProperty -> the property was appended directly
//   - (optional) the element  -> the property was appended
// DONE
- (SOProperty *)createPropertyForKeyNode:(SONode *)keyNode;
{
    SOProperty *property = nil;
    
    property = [[SOProperty alloc] initWithElement:self];
    property.keyNodeID = keyNode.id;
    
    // create the ID of this new property without a CONTEXT WRITE
    [[self context] registerProperty:property];                       // <-- special
    
    [self addProperty:property];
    
    return property;
}


// PreCondition: property shall have a
// DONE
- (void)addProperty:(SOProperty *)property;
{
    SOProperty *lastProperty = [[self propertyArray] lastObject];
    
    if (lastProperty) {
        // it seems this element has already one or more properties
        // add property to the last one
        property.previousPropertyID = lastProperty.id;
        lastProperty.nextPropertyID = property.id;
        
        // CONTEXT WRITE
        // updated of the LAST relationship is only required if
        // the is was extended
        [[self context] updateProperty:lastProperty];
        
    } else {
        // It seems this is the frist relationship
        
        // add relationship to the element  (e.g. Node -> Property)
        [self setPropertyID:property.id];
        
        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self update];
    }
    
    // CONTEXT WRTIE
    [[self context] updateProperty:property];
    
    // add property to internal array and maps
    [self addToPropertyArray:property];
}

// DONE
- (void)deleteProperty:(SOProperty *)aProperty;
{
    SOProperty *previousProperty = nil;
    SOProperty *nextProperty = nil;
    
    NSNumber *nextPropertyID = [aProperty nextPropertyID];
    NSNumber *previousPropertyID = [aProperty previousPropertyID];
    
    if (nextPropertyID) {
        nextProperty = [[self context] readProperty:nextPropertyID];
        
        [nextProperty setPreviousPropertyID:previousPropertyID];
        
        // CONTEXT WRITE
        [[self context] updateProperty:nextProperty];
    }
    
    if (previousPropertyID) {
        previousProperty = [[self context] readProperty:previousPropertyID];
        
        [previousProperty setNextPropertyID:nextPropertyID];
        
        // CONTEXT WRITE
        [[self context] updateProperty:previousProperty];
        
    } else {
        // seems this is the first property in the chain
        [self setPropertyID:nextPropertyID];


        // CONTEXT WRITE
        // update of self is only required if the id was set
        [self update];
    }
    
    // CONTEXT WRITE
    [aProperty delete];
    
    // update property to internal array and maps
    [self removeFromPropertyArray:aProperty];
}

@end

