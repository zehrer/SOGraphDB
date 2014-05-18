//
//  SOStringData.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 24.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//


// This class act as a wrapper of a NSData object created by encoding of a NString.
// The encode type is stored in the property encoding.
// The class support at the moment the two common encodings:
//  - NSUTF8StringEncoding -> prefered encoding as long it is smaller as the UTF-16 encoding
//  - NSUTF16StringEncoding -> if UTF-8 need more characters UTF-16 is used.
//
@interface SOStringData : NSObject

+ (NSString *)decodeData:(NSData *)aData withUTF8:(BOOL)isUTF8;

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) NSStringEncoding encoding;

@property (nonatomic, readonly) BOOL isUTF8Encoding;

@property (nonatomic, readonly) NSUInteger hash;

// provide direct access to the length of the data
@property (nonatomic, readonly) NSUInteger length;

- (instancetype)initWithString:(NSString *)text;

@end
