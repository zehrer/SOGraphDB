//
//  SOStringData.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 24.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import "SOStringData.h"

@implementation SOStringData

@synthesize hash = _hash;

+ (NSString *)decodeData:(NSData *)aData withUTF8:(BOOL)isUTF8;
{
    if (isUTF8) {
        return [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
    } else {
        return [[NSString alloc] initWithData:aData encoding:NSUnicodeStringEncoding];
    }
}


- (instancetype)initWithString:(NSString *)text;
{
    self = [super init];
    if (self) {
        
        NSData *dataUTF8 = [text dataUsingEncoding:NSUTF8StringEncoding];
        NSData *dataUTF16 = [text dataUsingEncoding:NSUTF16StringEncoding];
        
        if (dataUTF8.length <= dataUTF16.length) {
            _data = dataUTF8;
            _encoding = NSUTF8StringEncoding;
        } else {
            _data = dataUTF16;
            _encoding = NSUTF16StringEncoding;
        }
        
        _hash = [text hash];
    }
    return self;
}

- (BOOL)isUTF8Encoding;
{
    return (self.encoding == NSUTF8StringEncoding);
}

- (NSUInteger)length;
{
    return [self.data length];
}

@end
