//
//  SOCSVReader.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 03.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

@protocol SOCVSReadHandler <NSObject>

- (void)readLine:(NSArray *)items;

@end

@interface SOCSVReader : NSObject

@property id<SOCVSReadHandler> delegate;
@property (readonly )NSURL *url;
@property NSStringEncoding encoding;

- (instancetype)initWithURL:(NSURL *)aURL;

- (void)readCSVFile;

@end
