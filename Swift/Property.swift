//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public enum PropertyType: UInt8 {
    case Nil                // DEFAULT all values are nil
    case Bool               // Encode: DONE
    case Int                // Encode: DONE (longValue)
    case Double             // Encode: DONE
    case String             // Encode: DONE
    case StringExternal     // Encode by context : DONE
    case Date               // Encode: DONE
    case UUID               // Encode: DONE
    
    //case kNSURLType         = "C"  // TODO
    //case kNSRangeType       = "B"
    
    
    //case kUnsignedLongType  = "X"
    //case kNSNumberType
    //case kNSDecimalNumberType
    //case kNSDataType  --> file
    //case kSOIDType -->??
    //case kNSPointType
}

public struct Property : ValueStoreElement, Context {
    
    let maxStringLength = 20
    
    public weak var context : GraphContext! = nil
    
    public var uid: UID? = nil
    public var dirty = true
    
    var isNodeSource: Bool = false;         // 3  <- yes = property of a node / no = property of a relationship
    
    var sourceID: UID = 0 {              //  <- link to the source object
        didSet {
            if sourceID != oldValue {
                dirty = true
            }
        }
    }
    
    var keyNodeID: UID = 0 {     //  <- "type" of this property
        didSet {
            if keyNodeID != oldValue {
                dirty = true
            }
        }
    }

    var previousPropertyID: UID = 0 {            //  !<- 0 if start
        didSet {
            if previousPropertyID != oldValue {
                dirty = true
            }
        }
    }
    
    var nextPropertyID: UID = 0 {          //  !<- 0 if end
        didSet {
            if nextPropertyID != oldValue {
                dirty = true
            }
        }
    }
    
    public var type: PropertyType = .Nil;

    var uuid : NSUUID? = nil
    
    public init() {}
    
    public init (uid aID : UID) {
        uid = aID
    }

    public static func generateSizeTestInstance() -> Property {
        
        var result = Property()
        
        result.sourceID = Int(UInt32.max)
        
        result.keyNodeID = Int(UInt32.max)
        
        result.previousPropertyID = Int(UInt32.max)
        result.nextPropertyID = Int(UInt32.max)
        
        result._stringValue = "01234567890123456789"  // size 20
        
        return result
    }
    
    public init( related : PropertyAccess) {
        
        sourceID = related.uid!
        
        // default is false
        if related is Node {
            isNodeSource = true
        }
    }
    
    // MARK: ENCODE / DECODE
    
    public init(coder decoder: Decode) {
        
        type = PropertyType(rawValue: decoder.decode())!
       
        sourceID  = decoder.decode()
        isNodeSource = decoder.decode()
       
        keyNodeID = decoder.decode()
        
        previousPropertyID = decoder.decode()
        nextPropertyID = decoder.decode()
        
        
        switch type {
        case .String:
            //let stringDataUTF8 : NSData? = decoder.decode()
            _stringValue = decoder.decode()
        case .StringExternal:
            // read file later, at this point the file UUID and the context is not known
            break
        case .Bool:
            assertionFailure("TODO")
        case .Int:
             assertionFailure("TODO")
        case .Double:
             assertionFailure("TODO")
            //numberData = NSNumber(bool:decoder.decodeBoolForKey("0"))
           // numberData = (decoder.decodeObjectForKey("0") as! NSNumber)
        case .Date:
             dateValue = decoder.decode()
        case .UUID:
             assertionFailure("TODO")
            //uuid = (decoder.decodeObjectForKey("0") as! NSUUID)

        default:
            break
        }
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder : Encode) {
        
        encoder.encode(type.rawValue)
        
        encoder.encode(sourceID)
        encoder.encode(isNodeSource)
        
        
        encoder.encode(keyNodeID)
        
        encoder.encode(previousPropertyID)
        encoder.encode(nextPropertyID)
        
        switch type {
        case .String:
            //let stringDataUTF8 : NSData? = decoder.decode()
            encoder.encode(_stringValue!)
        case .StringExternal:
            // write
            context.writeString(_stringValue!, ofProperty: self)
            break
        case .Bool:
            encoder.encode(boolValue!)
        case .Int:
            encoder.encode(intValue!)
        case .Double:
            encoder.encode(doubleValue!)
        case .Date:
            assertionFailure("TODO")
            //dateData = (decoder.decodeObjectForKey("0") as! NSDate)
        case .UUID:
            assertionFailure("TODO")
            //uuid = (decoder.decodeObjectForKey("0") as! NSUUID)
        default:
            break
        }
        
    }
    
    // MARK: Types
    
    public var isNil : Bool {
        get {
            return type == .Nil
            
        }
    }
    
    // BOOL
    
    public var boolValue : Bool? {
        didSet {
            if boolValue != oldValue {
                if boolValue != nil {
                    type = .Bool
                } else {
                    type = .Nil
                }
                
                dirty = true
                update()
            }
        
        }
    }
    
    public var intValue : Int? {
        didSet {
            if intValue != oldValue {
                if intValue != nil {
                    type = .Int
                } else {
                    type = .Nil
                }
                
                dirty = true
                update()
            }
            
        }
    }

    public var doubleValue : Double? {
        didSet {
            if doubleValue != oldValue {
                if doubleValue != nil {
                    type = .Double
                } else {
                    type = .Nil
                }
                
                dirty = true
                update()
            }
            
        }
    }
    
    var _stringValue : String? = nil
    
    public var stringValue : String? {
        mutating get{
            switch (type) {
            case .Nil:
                return nil
            case .StringExternal:
                if _stringValue == nil {
                    // external value not read yet
                    _stringValue = context.readStringFor(self)
                }
                fallthrough
            case .String:
                return _stringValue
            default:
                return nil
            }
        }
        set {
            if _stringValue != newValue {
                _stringValue = newValue
                
                if let newValue = newValue {
                    // get size of encoded string
                    if newValue.utf8.count > maxStringLength {
                        type = .StringExternal
                    } else {
                        type = .String
                    }
                } else {
                    type = .Nil
                }
                
                dirty = true
                update()
            }
        }
    }
    
    public var dateValue : NSDate? {
        didSet {
            if dateValue != oldValue {
                if dateValue != nil {
                    type = .Date
                } else {
                    type = .Nil
                }
                
                dirty = true
                update()
            }
            
        }
    }
    
    // MARK: CRUD
    
    public mutating func update() {
        context.update(&self)
    }
    
    public mutating func delete() {
        context.delete(&self)
    }
    

}