//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

enum PropertyType: UInt8 {
    case kUndefined = 0
    case kBoolType  // bufferLength not used
    case kLongType
    case kUnsignedLongType
    case kDoubleType
    case kStringType
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
    
    public static let DEFAULT_VALUE : UInt8 = 255

    // header
    var isNodeSource: Bool = false;         // 1 Byte  <- yes = property of a node / no = property of a relationship
    var isUTF8Encoding: Bool = true;        // 1 Byte  <- yes internal string usues UTF8 / NO == UTF16
    
    // TODO use default length?
    var bufferLength: UInt8 = 0;            // 1 Byte
    
    var type: PropertyType = .kUndefined;   // 1 Byte
    
    var sourceID: UID = 0;                  // 4 Byte <- link to the source object
    
    var propertyKeyNodeID: UID = 0;         // 4 Byte <- "type" of this property
    
    var prevPropertyID: UID = 0;            // 4 Byte <- 0 if start
    var nextPropertyID: UID = 0;            // 4 Byte <- 0 if end
    
    var buffer = [UInt8](count: 20, repeatedValue: DEFAULT_VALUE)  // 20 Byte
    
    public init() {
        
    }
}  // 20 + 20 Buffer -> Size: 40 Byte 


public func == (lhs: Property, rhs: Property) -> Bool {
    return lhs.uid == rhs.uid
}

public class Property : GraphElement, Coding, Equatable {
    
    //MARK: Init
    
    public var data: PROPERTY = PROPERTY()
    
    var stringHash : Int? = nil
    //var stringStoreUID : UID? = nil

    public required init() {
    }
    
    // UseCase: Init with data during read
    required public init(data: PROPERTY) {
        //phase 1
        self.data = data
        super.init()
        //phase 2
        dirty = false
        
        // TODO: Decode data buffer
    }
    
    // UseCase: Create a new property
    required public init(graphElement:PropertyAccessElement, keyNode: Node) {
        //phase 1
        super.init()  // by default dirty = true
        //phase 2
        
        data.sourceID = graphElement.uid
        
        // default is false
        if graphElement is Node {
            data.isNodeSource = true;
        }
        
        self.keyNodeID = keyNode.uid
    }
    
    //MARK:Properties

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
    
    //MARK: CRUD TODO Protocol

    func delete() {
        context.deleteProperty(self)
    }
    
    func update() {
        if dirty {
            
            /**
            if (data.type == .kStringType) {
                stringStoreID = [self.context addString:self.data];
            }
            */
            context.updateProperty(self)
        }
    }
    
    //MARK: Basic Types
    
    //MARK: BOOL
    
    
    // 1 2 3 4 5 6 7 8
    // 1 1 1 1 1 1 1 1  => 255 => DEFAULT_VALUE
    // 1 0 1 0 0 1 0 1  => 165 => nil
    // 0 0 0 1 1 0 0 0  => 024 => true
    // 0 0 0 0 0 0 0 0  => 000 => false
    
    let FALSE_VALUE : UInt8 = 0
    let TRUE_VALUE : UInt8 = 24
    let NIL_VALUE : UInt8 = 165

    var boolValue : Bool? {
        get {
            switch data.buffer[0] {
            case FALSE_VALUE:
                return false
            case TRUE_VALUE:
                return true
            default:
                return nil
            }
        }
        set {
            if boolValue != newValue {
                self.dirty = true
                data.type = .kBoolType
                
                if (newValue != nil) {
                    
                    if (newValue!) {
                        data.buffer[0] = FALSE_VALUE
                    } else {
                        data.buffer[0] = TRUE_VALUE
                    }
                    
                } else {
                    data.buffer[0] = NIL_VALUE
                }
    
            }
        }
    
    }
    
    //MARK: INT (Int64)
    

}


