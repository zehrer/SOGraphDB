//
//  Entity.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 27.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSData * valueBin;
@property (nonatomic, retain) NSDecimalNumber * valueDecimal;
@property (nonatomic, retain) id valueTrans;
@property (nonatomic, retain) NSNumber * int64;
//@property (nonatomic, retain) NSNumber * double;

@end
