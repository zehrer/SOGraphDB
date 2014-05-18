//
//  SOStringDataStore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 20.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#import "SOStringStore.h"
#import "SODataStore.h"

@interface SOStringDataStore : SODataStore <SOStringStore>

// record unused segment positions in the file
// The set include NSNumer object of the type "unsignedLongLongValue"
@property (nonatomic, strong, readonly) NSMutableSet *unusedDataBlocks;

// index of the string hash to the index
@property (nonatomic, strong, readonly) NSMutableDictionary *stringHashIndex;

@end
