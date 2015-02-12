//
//  SOPropertyAccessElement.h
//  SOGraphDB
//
//  Created by Stephan Zehrer on 27.09.13.
//  Copyright (c) 2013 Stephan Zehrer. All rights reserved.
//

#import <SOGraphDB/SOGraphElement.h>
#import <SOGraphDB/SOPropertyAccess.h>

#import <SOGraphDB/SOProperty.h>

@interface SOPropertyAccessElement : SOGraphElement <SOPropertyAccess>

#pragma mark - Element property

@end

@interface SOPropertyAccessElement (Internal)

// DON'T USE
// 0 = there is not property for this node
// subclased have to override this setter
// DONE
@property (nonatomic) NSNumber *propertyID;

@end

