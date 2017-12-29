//
//  SOProperty.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 15.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOGraphDB/SOGraphElement.h> 

@class SOPropertyAccessElement;

@interface SOProperty : SOGraphElement<SOCoding>

- (instancetype)initWithElement:(SOPropertyAccessElement *)element;

// delete itself and related string store data;
- (void)delete;

#pragma mark - Low Level

@property (nonatomic, strong, readonly) id data;

#pragma mark - Basic Types

@property (nonatomic) BOOL boolValue;
@property (nonatomic) long longValue;
@property (nonatomic) unsigned long unsignedLongValue;
@property (nonatomic) double doubleValue;

#pragma mark - NSString

@property (nonatomic, strong) NSString *stringValue;

@end

@interface SOProperty (Internal)

// DON'T USE
// just available for testing
// 0 = there is not relationship for this node

@property (nonatomic, readonly, getter = isNodeSource) BOOL isNodeSource;

@property (nonatomic, readonly) NSNumber *sourceID;

@property (nonatomic) NSNumber *nextPropertyID;
@property (nonatomic) NSNumber *previousPropertyID;

@property (nonatomic) NSNumber *keyNodeID;

@end

/**
 
 //- (BOOL)isType:(const char *)type;

 //@property (nonatomic, strong) NSNumber *number;


*/