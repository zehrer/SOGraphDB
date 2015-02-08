//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

enum PropertyType: UInt8 {
    case kUndefined = 0
    case kBoolType
    case kLongType
    case kUnsignedLongType
    case kDoubleType
    case kNSStringType
    // case kNSNumberType
    // case kNSDataType
    // case kSOIDType
    case kNSDateType
    // case kNSPointType
    case kNSRangeType
    case kNSDecimalType
    case kNSUUIDType
    case kNSURLType               // may not work
}


struct PROPERTY : Init {

    var isNodeSource: Bool = false;         // 1 Byte  <- yes = property of a node / no = property of a relationship
    var isUTF8Encoding: Bool = true;        // 1 Byte  <- yes internal string usues UTF8 / NO == UTF16
    
    var bufferLength: UInt8 = 0;            // 1 Byte
    
    var type: PropertyType = .kUndefined;   // 1 Byte
    
    var sourceID: UID = 0;                  // 4 Byte <- link to the source object
    
    var propertyKeyNodeID: UID = 0;         // 4 Byte <- "type" of this property
    
    var prevPropertyID: UID = 0;            // 4 Byte <- 0 if start
    var nextPropertyID: UID = 0;            // 4 Byte <- 0 if end
    
    init() {
        
    }
}  // 20 ???



class Property : GraphElement, Coding {
    
    var data: PROPERTY = PROPERTY()
    
     required init() {
        
    }
    
    //decoding NSData
    required init(data: PROPERTY) {
        self.data = data
    }

}

