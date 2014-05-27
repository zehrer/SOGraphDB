//
//  SOTools.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 16.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//


#define RAND_FROM_TO(min,max) (min + arc4random_uniform(max - min + 1))

@interface SOTools : NSObject

+ (NSURL *)tempDirectory;

@end
