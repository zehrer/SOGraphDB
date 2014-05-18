//
//  SOIndexObject.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 22.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOCoding.h"

@class SOStringData;

// initWithData is not supported !!
@interface SOTextIndexObject : NSObject <SOCoding>

@property (nonatomic, getter = isUsed, setter = setUsed:) BOOL used;
@property (nonatomic, getter = isUTF8Encoding, setter = setUTF8Encoding:) BOOL isUTF8Encoding;

// The setter of this property updates endocding and length settings too.
// But only if you set it to a object value. If set to nil the length and encoding is keept.
@property (nonatomic, strong) SOStringData *stringData;

@property (nonatomic) unsigned long long pos;
@property (nonatomic) unsigned long length;

#pragma mark - SOIndexObject Methodes

+ (unsigned long)dataSize;

#pragma mark - SOIndexObject Methodes

- (instancetype)initWithIndexObject:(SOTextIndexObject *)aIndexObject;

- (instancetype)initWithStringData:(SOStringData *)aStringData;

- (instancetype)initWithID:(NSUInteger)aID;

- (NSString *)decodeString:(NSData *)data;

@end
