//
//  Property.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public enum PropertyType: UInt8 {
    case `nil`                // DEFAULT all values are nil
    case bool               // Encode: DONE
    case int                // Encode: DONE (longValue)
    case double             // Encode: DONE
    case string             // Encode: DONE
    case stringExternal     // Encode by context : DONE
    case date               // Encode: DONE
    case uuid               // Encode: DONE
    
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
    
    var sourceID: UID = 0  // the ID of the related node or relationship
    var keyNodeID: UID = 0

    var previousPropertyID: UID = 0
    var nextPropertyID: UID = 0

    
    public var type: PropertyType = .nil;

    var uuid : UUID? = nil
    
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
        case .string:
            //let stringDataUTF8 : NSData? = decoder.decode()
            _stringValue = decoder.decode()
        case .stringExternal:
            // read file later, at this point the file UUID and the context is not known
            break
        case .bool:
            assertionFailure("TODO")
        case .int:
             assertionFailure("TODO")
        case .double:
             assertionFailure("TODO")
            //numberData = NSNumber(bool:decoder.decodeBoolForKey("0"))
           // numberData = (decoder.decodeObjectForKey("0") as! NSNumber)
        case .date:
             dateValue = decoder.decode()
        case .uuid:
             assertionFailure("TODO")
            //uuid = (decoder.decodeObjectForKey("0") as! NSUUID)

        default:
            break
        }
        
        dirty = false
    }
    
    public func encodeWithCoder(_ encoder : Encode) {
        
        encoder.encode(type.rawValue)
        
        encoder.encode(sourceID)
        encoder.encode(isNodeSource)
        
        
        encoder.encode(keyNodeID)
        
        encoder.encode(previousPropertyID)
        encoder.encode(nextPropertyID)
        
        switch type {
        case .string:
            //let stringDataUTF8 : NSData? = decoder.decode()
            encoder.encode(_stringValue!)
        case .stringExternal:
            // write
            context.writeString(_stringValue!, ofProperty: self)
            break
        case .bool:
            encoder.encode(boolValue!)
        case .int:
            encoder.encode(intValue!)
        case .double:
            encoder.encode(doubleValue!)
        case .date:
            assertionFailure("TODO")
            //dateData = (decoder.decodeObjectForKey("0") as! NSDate)
        case .uuid:
            assertionFailure("TODO")
            //uuid = (decoder.decodeObjectForKey("0") as! NSUUID)
        default:
            break
        }
        
    }
    
    // MARK: Types
    
    public var isNil : Bool {
        get {
            return type == .nil
            
        }
    }
    
    // BOOL
    
    public var boolValue : Bool? {
        didSet {
            if boolValue != oldValue {
                if boolValue != nil {
                    type = .bool
                } else {
                    type = .nil
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
                    type = .int
                } else {
                    type = .nil
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
                    type = .double
                } else {
                    type = .nil
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
            case .nil:
                return nil
            case .stringExternal:
                if _stringValue == nil {
                    // external value not read yet
                    _stringValue = context.readStringFor(self)
                }
                fallthrough
            case .string:
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
                        type = .stringExternal
                    } else {
                        type = .string
                    }
                } else {
                    type = .nil
                }
                
                dirty = true
                update()
            }
        }
    }
    
    public var dateValue : Date? {
        didSet {
            if dateValue != oldValue {
                if dateValue != nil {
                    type = .date
                } else {
                    type = .nil
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
