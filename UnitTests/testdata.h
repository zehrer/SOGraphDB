//
//  testdata.h
//  SOCoreGraph
//
//  Created by Stephan Zehrer on 21.04.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

#ifndef SOCoreGraph_testdata_h
#define SOCoreGraph_testdata_h

static NSString *const testStringUTF8 = @"01234567890123456789";
static NSString *const testStringUTF8U1 = @"98765432109876543210";           //20   // use case 1 update: same size
static NSString *const testStringUTF8U2 = @"987654321098";                   //12   // use case 2 update: smaller size
static NSString *const testStringUTF8U3 = @"987654321098765432109876543210"; //30    // use case 3 update: larger size
static NSString *const testStringUTF16 = @"\u6523\u6523\u6523\u6523";        //10   // should be better in UTF16 as in UTF8


#endif
