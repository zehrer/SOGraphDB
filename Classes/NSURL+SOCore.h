//
//  NSURL+SOCore.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 21.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SOCore)

- (BOOL)isFileExisting;
- (void)deleteFile;

@end
