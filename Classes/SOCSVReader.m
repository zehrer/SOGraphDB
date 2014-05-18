//
//  SOCSVReader.m
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 03.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "SOCSVReader.h"

@implementation SOCSVReader

- (instancetype)initWithURL:(NSURL *)aURL;
{
    self = [super init];
    if (self) {
         _url = aURL;
        self.encoding = NSUTF8StringEncoding;
    }
    return self;
    
}

- (void)readCSVFile;
{
    NSError *error;
    NSString *dataString = [[NSString alloc] initWithContentsOfURL:self.url encoding:self.encoding error:&error];
    
    // Source: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Strings/Articles/stringsParagraphBreaks.html#//apple_ref/doc/uid/TP40005016-SW2
    
    NSUInteger length = [dataString length];
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSRange currentRange;
    NSString *line;
    
    while (paraEnd < length) {
        [dataString getParagraphStart:&paraStart end:&paraEnd
                          contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        
        //NSLog(@"%@", [dataString substringWithRange:currentRange]);
        
        line = [dataString substringWithRange:currentRange];
        NSArray *items = [line componentsSeparatedByString:@","];
        
        [self.delegate readLine:items];
    }
    
}


@end
