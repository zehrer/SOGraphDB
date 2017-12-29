//
//  NSValue+SOCoreGraph.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 29.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (SOCoreGraph)

- (NSMutableData *)createMutableDataObject;

- (NSData *)createDataObject;

@end
