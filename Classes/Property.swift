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


public struct PROPERTY : Init {

    var isNodeSource: Bool = false;         // 1 Byte  <- yes = property of a node / no = property of a relationship
    var isUTF8Encoding: Bool = true;        // 1 Byte  <- yes internal string usues UTF8 / NO == UTF16
    
    // TODO use default length?
    var bufferLength: UInt8 = 0;            // 1 Byte
    
    var type: PropertyType = .kUndefined;   // 1 Byte
    
    var sourceID: UID = 0;                  // 4 Byte <- link to the source object
    
    var propertyKeyNodeID: UID = 0;         // 4 Byte <- "type" of this property
    
    var prevPropertyID: UID = 0;            // 4 Byte <- 0 if start
    var nextPropertyID: UID = 0;            // 4 Byte <- 0 if end
    
    public init() {
        
    }
}  // 20 ???


public func == (lhs: Property, rhs: Property) -> Bool {
    return lhs.uid == rhs.uid
}

public class Property : GraphElement, Coding, Equatable {
    
    public var data: PROPERTY = PROPERTY()
    
    public required init() {
    }
    
    //init with external value
    required public init(data: PROPERTY) {
        //phase 1
        self.data = data
        super.init()
        //phase 2
        dirty = false
    }
    
    required public init(graphElement:PropertyAccessElement, keyNode: Node) {
        //phase 1
        super.init()
        //phase 2
        
        data.sourceID = graphElement.uid
        
        // default is false
        if graphElement is Node {
            data.isNodeSource = true;
        }
        
        self.keyNodeID = keyNode.uid
        
        //data.bufferLength = BUFFER_LEN;
    }
    

    // only available for testing, not public
    var previousPropertyID : UID {
        get {
            return data.prevPropertyID
        }
        set {
            if newValue != data.prevPropertyID {
                data.prevPropertyID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var nextPropertyID : UID {
        get {
            return data.nextPropertyID
        }
        set {
            if newValue != data.nextPropertyID {
                data.nextPropertyID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var keyNodeID : UID {
        get {
            return data.propertyKeyNodeID
        }
        set {
            if newValue != data.propertyKeyNodeID {
                data.propertyKeyNodeID = newValue
                dirty = true
            }
        }
    }
    

}

