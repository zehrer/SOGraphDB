//
//  NSStoreCoder.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 29.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//


// This class does not encode the type.
@interface NSStoreCoder : NSCoder

#pragma mark - encode

@property (nonatomic, strong) NSMutableData *data;

+ (NSMutableData *)encodeNSNumber:(NSNumber *)aNumber;

- (void)encodeNSNumber:(NSNumber *)aNumber;
//- (void)encodeNSDecimalNumber:(NSDecimalNumber *)aNumber;

- (NSMutableData *)encodeData;

#pragma mark - decode

- (NSNumber *)decodeNSNumber:(NSData *)data;

@end
