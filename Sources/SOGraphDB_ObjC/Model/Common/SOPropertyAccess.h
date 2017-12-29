//
//  SOPropertyAccess.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

@class SONode;

@protocol SOPropertyAccess <NSObject>

#pragma mark General

- (id)deleteValueforKey:(SONode *)keyNode;

#pragma mark NSNumber (NSValue)

- (void)setLongValue:(long)aValue forKey:(SONode *)keyNode;
- (long)longValueForKey:(SONode *)keyNode;

- (void)setUnsignedLongValue:(unsigned long)aValue forKey:(SONode *)keyNode;
- (unsigned long)unsignedLongValueForKey:(SONode *)keyNode;

- (void)setDoubleValue:(double)aValue forKey:(SONode *)keyNode;
- (double)doubleValueForKey:(SONode *)keyNode;

/**
- (void)setNumberProperty:(NSNumber *)aNumber forKey:(SONode *)keyNode;
- (NSNumber *)numberPropertyForKey:(SONode *)keyNode;

- (void)setDecimalProperty:(NSDecimalNumber *)aNumber forKey:(SONode *)keyNode;
- (NSDecimalNumber *)decimalPropertyForKey:(SONode *)keyNode;
 */

#pragma mark NSString

- (void)setStringValue:(NSString *)text forKey:(SONode *)keyNode;
- (NSString *)stringValueForKey:(SONode *)keyNode;

#pragma mark Other

- (void)setDateValue:(NSDate *)aNumber forKey:(SONode *)keyNode;
- (NSDate *)dateValueForKey:(SONode *)keyNode;

- (void)setURLValue:(NSURL *)aNumber forKey:(SONode *)keyNode;
- (NSURL *)urlValueForKey:(SONode *)keyNode;

- (void)setUUIDValue:(NSUUID *)aNumber forKey:(SONode *)keyNode;
- (NSUUID *)uuidValueForKey:(SONode *)keyNode;


// TODO
// NSRange
// NSPoint
// MapKit elemet?
// Reminder element
// Calender element?
//

@end
