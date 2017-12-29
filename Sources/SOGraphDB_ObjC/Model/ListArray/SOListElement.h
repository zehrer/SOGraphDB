//
//  SOListElement.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 12.10.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//


@protocol SOListElement <NSObject>

@property (nonatomic) NSNumber *id;

@property (nonatomic) NSNumber *nextElementID;
@property (nonatomic) NSNumber *previousElementID;

- (void)update;
- (void)delete;

@end
