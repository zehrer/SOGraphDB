//
//  SOGraphDB.h
//  SOGraphDB
//
//  Created by Stephan Zehrer on 03.05.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#include "TargetConditionals.h"


/**
#if os(iOS)
#else
// Other kinds of Mac OS
#endif
*/

#ifdef TARGET_OS_MAC
// we are on MacOS

#elif defined TARGET_OS_IPHONE
 // we are on iOS

#import <UIKit/UIKit.h>

//! Project version number for SOGraphDB-iOS.
FOUNDATION_EXPORT double SOGraphDB_iOSVersionNumber;

//! Project version string for SOGraphDB-iOS.
FOUNDATION_EXPORT const unsigned char SOGraphDB_iOSVersionString[];

#else
// unknown platform

#endif


// In this header, you should import all the public headers of your framework using statements like #import <SOGraphDB/PublicHeader.h>

#import <SOGraphDB/SOCoding.h>

#import <SOGraphDB/SOGraphContext.h>

#import <SOGraphDB/SOGraphElement.h>

#import <SOGraphDB/SONode.h>
#import <SOGraphDB/SORelationship.h>
#import <SOGraphDB/SOProperty.h>
#import <SOGraphDB/SOPropertyAccess.h>
#import <SOGraphDB/SOPropertyAccessElement.h>

#import <SOGraphDB/SOFileStore.h>
#import <SOGraphDB/SODataStore.h>
#import <SOGraphDB/SOObjectStore.h>
#import <SOGraphDB/SOManagedDataStore.h>
#import <SOGraphDB/SOCacheDataStore.h>

#import <SOGraphDB/SOStringData.h>
#import <SOGraphDB/SOStringStore.h>
#import <SOGraphDB/SOStringDataStore.h>

#import <SOGraphDB/SOElementList.h> 
#import <SOGraphDB/SOListElement.h>

#import <SOGraphDB/NSURL+SOCore.h>
#import <SOGraphDB/NSStoreCoder.h>
#import <SOGraphDB/NSData+SOCoreGraph.h>

#import <SOGraphDB/SOCSVReader.h>
#import <SOGraphDB/SOTools.h>
#import <SOGraphDB/NSNumber+SOCoreGraph.h>

#import <SOGraphDB/FastCoder.h>