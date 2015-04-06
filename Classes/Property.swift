//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

public enum PropertyType: String {
    case tUndefined         = "1" // NO ENCODE
    case tBool              = "2" // Encode: DONE
    case tInt               = "3" // Encode: DONE (longValue)
    case tDouble            = "4" // Encode: DONE
    case tString            = "5" // Encode: partially done (length check TODO)
    case tNSDate            = "7" // TODO
    case tNSUUID            = "8" // TODO
    
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
}


public func == (lhs: Property, rhs: Property) -> Bool {
    return lhs.uid == rhs.uid
}



public class Property : GraphElement, Coding, Equatable, NSCoding {
    
    let maxStingDataLength = 20
    
    //MARK: Data
    public var type: PropertyType = .tUndefined;

    var numberData : NSNumber? = nil
    var stringData : String? = nil
    var dateData : NSDate? = nil
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
            case .tString:
                var stringDataUTF8 = (decoder.decodeObjectForKey("0") as NSData?)
                if (stringDataUTF8 == nil) {
                    println("Read text file?")
                } else {
                    stringData = NSString(data:stringDataUTF8!, encoding: NSUTF8StringEncoding)
                }
                
                // stringData = (decoder.decodeObjectForKey("0") as String)
            case .tBool, .tInt, .tDouble:
            //numberData = NSNumber(bool:decoder.decodeBoolForKey("0"))
                numberData = (decoder.decodeObjectForKey("0") as NSNumber)
            case .tNSDate:
                dateData = (decoder.decodeObjectForKey("0") as NSDate)
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
            case .tString:
                // TODO: add encode to UTF16 support
                // TODO: use other coder
                var stringDataUTF8 = stringData!.dataUsingEncoding(NSUTF8StringEncoding)
                
                
                // //println("\(stringDataUTF8!.length)")
                if stringDataUTF8!.length > maxStingDataLength {
                    println("TODO: store in text file")
                } else {
                    encoder.encodeObject(stringDataUTF8,forKey:"0")
                }
                //encoder.encodeObject(stringData!,forKey:"0")
            case .tBool, .tInt, .tDouble:
                //encoder.encodeBool(numberData!.boolValue, forKey:"0")
                encoder.encodeObject(numberData!, forKey:"0")
            case .tNSDate:
                encoder.encodeObject(dateData!, forKey:"0")
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
            if (data.type == .tString) {
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
            case  .tString:
                return stringData
            default:
                return numberData
            }
        }
    }
    
    public var isNil : Bool {
        get {
            switch type {
            // Number Data is handeld in default case
            case .tString:
                return stringData == nil
            case .tNSDate:
                return dateData == nil
            case .tNSUUID:
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
                type = .tBool
                
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
                type = .tInt
                
                if (newValue != nil) {
                    numberData = NSNumber(long:newValue!)
                } else {
                    numberData = nil
                }
                
            }
        }
        
    }
    
    //MARK: DOUBLE
    
    public var doubleValue : Double? {
        get {
            if numberData != nil {
                return numberData!.doubleValue
            }
            return nil
        }
        set {
            if doubleValue != newValue {
                dirty = true
                type = .tDouble
                
                if (newValue != nil) {
                    numberData = NSNumber(double:newValue!)
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
                type = .tString
                
                stringData = newValue
            }
        }
    }
    
    //MARK: NSDate
    
    public var dateValue : NSDate? {
        get{
            return dateData
        }
        set {
            if dateData != newValue {
                dirty = true
                type = .tNSDate
                
                dateData = newValue
            }
        }
    }
}


