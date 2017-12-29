//
//  NSNumber+SOCoreGraph.h
//  SOGraphDB
//
//  Created by Stephan Zehrer on 20.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

typedef unsigned int SOID;

#import <Foundation/Foundation.h>

@interface NSNumber (SOCoreGraph)

+ (instancetype)numberWithID:(SOID)aID;

- (SOID)ID;

- (NSData *)encode;

@end
