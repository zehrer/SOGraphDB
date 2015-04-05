//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

public enum PropertyType: String {
    case kUndefined         = "1" // NO ENCODE
    case kBoolType          = "2" // Encode: DONE
    case kIntType           = "3" // Encode: DONE (longValue)
    case kDoubleType        = "4" // Encode: DONE
    case kStringType        = "5" // Encode: partially done (length check TODO)
    case kNSDateType        = "6" // TODO
    case kNSUUIDType        = "7" // TODO
    
    //case kNSURLType         = "C"  // TODO
    //case kNSRangeType       = "B"
    
   
    //case kUnsignedLongType  = "X"
    //case kNSNumberType
    //case kNSDecimalNumberType
    //case kNSDataType  --> file
    //case kSOIDType -->??
    //case kNSPointType
}


public struct PROPERTY : Init {

    //var type: PropertyType = .kUndefined;   // 1
    
    var isNodeSource: Bool = false;         // 3  <- yes = property of a node / no = property of a relationship
    //var isUTF8Encoding: Bool = true;      // --  <- yes internal string usues UTF8 / NO == UTF16
    
    // TODO use default length?
    //var bufferLength: UInt8 = 0;          // --
    
    var sourceID: UID = 0;                  //  <- link to the source object
    
    var propertyKeyNodeID: UID = 0;         //  <- "type" of this property
    
    var prevPropertyID: UID = 0;            //  !<- 0 if start
    var nextPropertyID: UID = 0;            //  !<- 0 if end

    
    public init() {
        
    }
}  // 20 + 20 Buffer -> Size: 40 Byte 


public func == (lhs: Property, rhs: Property) -> Bool {
    return lhs.uid == rhs.uid
}

public class Property : GraphElement, Coding, Equatable, NSCoding {
    
    //MARK: Data
    public var type: PropertyType = .kUndefined;

    var numberData : NSNumber? = nil
    var stringData : String? = nil
    //var stringHash : Int? = nil
    //var stringStoreUID : UID? = nil
    
    // old
    public var data: PROPERTY = PROPERTY()
    
    //MARK: NSCoding
    
    required public init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        type = PropertyType(rawValue: decoder.decodeObjectForKey("1") as String)!
        var nilValue = decoder.decodeBoolForKey("2")
        
        data.isNodeSource = decoder.decodeBoolForKey("3")
        
        data.sourceID  = decoder.decodeIntegerForKey("4")
        
        data.propertyKeyNodeID = decoder.decodeIntegerForKey("5")
        
        data.prevPropertyID = decoder.decodeIntegerForKey("6")
        data.nextPropertyID = decoder.decodeIntegerForKey("7")
        
        if (!nilValue) {
            switch (type) {
            case .kStringType:
                stringData = (decoder.decodeObjectForKey("0") as String)
            case .kBoolType, .kIntType, .kDoubleType:
            //numberData = NSNumber(bool:decoder.decodeBoolForKey("0"))
                numberData = (decoder.decodeObjectForKey("0") as NSNumber)
            //case .kIntType:
                //numberData = NSNumber(long:decoder.decodeIntegerForKey("0"))
             //   numberData = (decoder.decodeObjectForKey("0") as NSNumber)
            //case .kDoubleType:
            //    numberData = NSNumber(double:decoder.decodeDoubleForKey("0"))
            default:
                print("WARNING: Encoding Property and not handled default case")
            }
            
        }

    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(type.rawValue,forKey:"1")
        encoder.encodeBool(isNil, forKey:"2")
        
        encoder.encodeBool(data.isNodeSource,forKey:"3")
        
        encoder.encodeInteger(data.sourceID, forKey:"4")
        
        encoder.encodeInteger(data.propertyKeyNodeID, forKey:"5")
        
        encoder.encodeInteger(data.prevPropertyID, forKey:"6")
        encoder.encodeInteger(data.nextPropertyID, forKey:"7")
        
        if (!isNil) {
            switch (type) {
            case .kStringType:
                encoder.encodeObject(stringData!,forKey:"0")
            case .kBoolType, .kIntType, .kDoubleType:
                //encoder.encodeBool(numberData!.boolValue, forKey:"0")
                encoder.encodeObject(numberData!, forKey:"0")
            //case .kIntType:
                //encoder.encodeInteger(numberData!.longValue, forKey:"0")
            //    encoder.encodeObject(numberData!, forKey:"0")
            //case .kDoubleType:
            //    encoder.encodeDouble(numberData!.doubleValue, forKey:"0")
            default:
                print("WARNING: Encoding Property and not handled default case")
            }
        }
    }
    
    //MARK: Init

    public required init() {
    }
    
    // TODO REMOVE
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
    
    //MARK: Basic access interface
    
    public var value : AnyObject? {
        get {
            switch type {
            case  .kStringType:
                return stringData
            default:
                return numberData
            }
        }
    }
    
    public var isNil : Bool {
        get {
            switch type {
            case .kStringType:
                return stringData == nil
            case .kNSUUIDType:
                return true
            case .kNSDateType:
                return true
            default:
                return numberData == nil
            }
            
        }
    }
    
    //MARK: Basic Types
    
    //MARK: BOOL

    public var boolValue : Bool? {
        get {
            if numberData != nil {
                return numberData!.boolValue
            }
            return nil
        }
        set {
            if boolValue != newValue {
                dirty = true
                type = .kBoolType
                
                if (newValue != nil) {
                    numberData = NSNumber(bool:newValue!)
                } else {
                    numberData = nil
                }
    
            }
        }
    
    }
    
    //MARK: INT 
    
    public var intValue : Int? {
        get {
            if numberData != nil {
                return numberData!.longValue
            }
            return nil
        }
        set {
            if intValue != newValue {
                dirty = true
                type = .kIntType
                
                if (newValue != nil) {
                    numberData = NSNumber(long:newValue!)
                } else {
                    numberData = nil
                }
                
            }
        }
        
    }
    
    //MARK: STRING
    
    public var stringValue : String? {
        get{
            return stringData
        }
        set {
            if stringData != newValue {
                dirty = true
                type = .kStringType
                
                stringData = newValue
            }
        }
    }
}


