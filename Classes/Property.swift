//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

public enum PropertyType: String {
    case tNIL               = "0" // DEFAULT all values are nil
    case tBool              = "b" // Encode: DONE
    case tInt               = "i" // Encode: DONE (longValue)
    case tDouble            = "d" // Encode: DONE
    case tString            = "s" // Encode: DONE
    case tStringExternal    = "S" // Encode by context : DONE
    case tNSDate            = "a" // Encode: DONE
    case tNSUUID            = "u" // Encode: DONE
    
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


//@objc(property)
public class Property : GraphElement, Coding, ObjectStoreElement { // Equatable
    
    // measured by count(string.UTF8)
    let maxStringLength = 20
    
    //MARK: Data
    public var type: PropertyType = .tNIL;

    var numberData : NSNumber? = nil
    var stringData : String? = nil
    var dateData : NSDate? = nil
    var uuid : NSUUID? = nil
    //var stringHash : Int? = nil
    //var stringStoreUID : UID? = nil
    
    // old
    public var data: PROPERTY = PROPERTY()
    
    //MARK: NSCoding
    
    required public init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        type = PropertyType(rawValue: decoder.decodeObjectForKey("1") as! String)!
        
        data.isNodeSource = decoder.decodeBoolForKey("2")
        
        data.sourceID  = decoder.decodeIntegerForKey("3")
        
        data.propertyKeyNodeID = decoder.decodeIntegerForKey("4")
        
        data.prevPropertyID = decoder.decodeIntegerForKey("5")
        data.nextPropertyID = decoder.decodeIntegerForKey("6")
        
        switch (type) {
        case .tString:
            let stringDataUTF8 = (decoder.decodeObjectForKey("0") as! NSData)
            stringData = NSString(data:stringDataUTF8, encoding: NSUTF8StringEncoding) as? String
        case .tStringExternal:
            // read file later, at this point the file UUID is not known
            // second soluton: write
            // stringData = (decoder.decodeObjectForKey("0") as String)
            
            break
        case .tBool, .tInt, .tDouble:
            //numberData = NSNumber(bool:decoder.decodeBoolForKey("0"))
            numberData = (decoder.decodeObjectForKey("0") as! NSNumber)
        case .tNSDate:
            dateData = (decoder.decodeObjectForKey("0") as! NSDate)
        case .tNSUUID:
            uuid = (decoder.decodeObjectForKey("0") as! NSUUID)
        default:
            break
        }

    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        
        encoder.encodeObject(type.rawValue,forKey:"1")
        
        encoder.encodeBool(data.isNodeSource,forKey:"2")
        
        encoder.encodeInteger(data.sourceID, forKey:"3")
        
        encoder.encodeInteger(data.propertyKeyNodeID, forKey:"4")
        
        encoder.encodeInteger(data.prevPropertyID, forKey:"5")
        encoder.encodeInteger(data.nextPropertyID, forKey:"6")
        
        if (!isNil) {
            switch (type) {
            case .tString:
                let stringDataUTF8 = stringData!.dataUsingEncoding(NSUTF8StringEncoding)
                
                if (stringDataUTF8 != nil) {
                    // println("\(stringDataUTF8!.length)")
                    encoder.encodeObject(stringDataUTF8,forKey:"0")

                } else {
                    assertionFailure("Problem with encoding of String, why?")
                }
                //encoder.encodeObject(stringData!,forKey:"0")
            case .tStringExternal:
                if uid != nil {
                    encoder.encodeInteger(uid!, forKey:"0")
                }
                // we encode our own UID
                //
                // encode the string in
                //context!.writeStringData(stringDataUTF8!, ofProperty:self)
                //stringDataUTF8!.writeToURL(stringFileName(), atomically: true)
                break
            case .tBool, .tInt, .tDouble:
                //encoder.encodeBool(numberData!.boolValue, forKey:"0")
                encoder.encodeObject(numberData!, forKey:"0")
            case .tNSDate:
                encoder.encodeObject(dateData!, forKey:"0")
            case .tNSUUID:
                encoder.encodeObject(uuid!, forKey:"0")
            default:
                print("WARNING: Encoding Property and not handled default case")
            }
        }
    }
    
    public static func dataSize() -> Int {
        return 100
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
    required public init(graphElement : PropertyAccessElement, keyNode: Node) {
        
        // TODO test UID
        
        //phase 1
        super.init()  // by default dirty = true
        //phase 2
        
        data.sourceID = graphElement.uid!
        
        // default is false
        if graphElement is Node {
            data.isNodeSource = true;
        }
        
        self.keyNodeID = keyNode.uid!
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
        if context != nil {
            context!.deleteProperty(self)
        }
    }
    
    func update() {
        
        if dirty {
            
            if (context != nil) {
                context!.updateProperty(self)
                
                
                // TODO: delete possile text files
                
                if type == .tStringExternal {
                    if context != nil {
                        context!.writeString(stringData!, ofProperty: self)
                    }
                }
                
            }
            
            /**
            if (data.type == .tString) {
                stringStoreID = [self.context addString:self.data];
            }
            */

        }
    }
    
    //MARK: Basic access interface
    
    /**
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
    */
    
    public var isNil : Bool {
        get {
            return type == .tNIL
            
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
                
                if (newValue != nil) {
                    numberData = NSNumber(bool:newValue!)
                    type = .tBool
                } else {
                    numberData = nil
                    type = .tNIL
                }
    
                update()
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
                
                if (newValue != nil) {
                    numberData = NSNumber(long:newValue!)
                    type = .tInt
                } else {
                    numberData = nil
                    type = .tNIL
                }
                
                update()
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
                
                if (newValue != nil) {
                    numberData = NSNumber(double:newValue!)
                    type = .tDouble
                } else {
                    numberData = nil
                    type = .tNIL
                }
                
                update()
            }
        }
        
    }
    
    //MARK: STRING
    
    public var stringValue : String? {
        get{
            switch (type) {
            case .tStringExternal:
                if stringData == nil && context != nil {
                    stringData = context!.readStringFor(self)
                }
                fallthrough
            case .tString:
                return stringData
            default:
                return nil
            }
        }
        set {
            if stringData != newValue {
                
                if let newValue = newValue {
                    // get size of encoded string
                    if newValue.utf8.count > maxStringLength {
                        type = .tStringExternal
                    } else {
                        type = .tString
                    }
                } else {
                    type = .tNIL
                }
                
                dirty = true
                stringData = newValue
                
                update()
            }
        }
    }
    
    //MARK: NSDate
    
    public var dateValue : NSDate? {
        get{
            if type == .tNSDate {
                return dateData
            }
            return nil
        }
        set {
            if dateData != newValue {
                dirty = true
                
                if newValue != nil {
                    type = .tNSDate
                }  else {
                    type = .tNIL
                }
            
                dateData = newValue
                
                update()
            }
        }
    }
    
    // MARK: UUID
    
    
}


