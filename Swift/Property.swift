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
    
    var sourceID: UID = 0;                  //  <- link to the source object
    
    var keyNodeID: UID = 0;         //  <- "type" of this property
    
    var previousPropertyID: UID = 0;            //  !<- 0 if start
    var nextPropertyID: UID = 0;            //  !<- 0 if end
    
    public var type: PropertyType = .Nil;
    
    var numberData : NSNumber? = nil
    var stringData : String? = nil
    var dateData : NSDate? = nil
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
        
        result.stringData = "01234567890123456789"  // size 20
        
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
        
        isNodeSource = decoder.decode()
        sourceID  = decoder.decode()
        
        keyNodeID = decoder.decode()
        previousPropertyID = decoder.decode()
        nextPropertyID = decoder.decode()
        
        
        switch type {
        case .String:
            //let stringDataUTF8 : NSData? = decoder.decode()
            stringData = decoder.decode()
        case .StringExternal:
            // read file later, at this point the file UUID is not known
            // second soluton: write
            // stringData = (decoder.decodeObjectForKey("0") as String)
            
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
             assertionFailure("TODO")
            //dateData = (decoder.decodeObjectForKey("0") as! NSDate)
        case .UUID:
             assertionFailure("TODO")
            //uuid = (decoder.decodeObjectForKey("0") as! NSUUID)
        default:
            break
        }
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder : Encode) {
        encoder.encode(isNodeSource)
        encoder.encode(sourceID)
        
        encoder.encode(keyNodeID)
        encoder.encode(previousPropertyID)
        encoder.encode(nextPropertyID)
    }
    
    //
    public mutating func delete() {
        context.delete(&self)
    }
}