//
//  DataCoder.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

enum FCType : UInt8 {
        case FCTypeNil = 0
        case FCTypeNull
        case FCTypeObjectAlias8
        case FCTypeObjectAlias16
        case FCTypeObjectAlias32
        case FCTypeStringAlias8
        case FCTypeStringAlias16
        case FCTypeStringAlias32
        case FCTypeString
        case FCTypeDictionary
        case FCTypeArray
        case FCTypeSet
        case FCTypeOrderedSet
        case FCTypeTrue
        case FCTypeFalse
        case FCTypeInt8
        case FCTypeInt16
        case FCTypeInt32
        case FCTypeInt64
        case FCTypeFloat32
        case FCTypeFloat64
        case FCTypeData
        case FCTypeDate
        case FCTypeMutableString
        case FCTypeMutableDictionary
        case FCTypeMutableArray
        case FCTypeMutableSet
        case FCTypeMutableOrderedSet
        case FCTypeMutableData
        case FCTypeClassDefinition
        case FCTypeObject8
        case FCTypeObject16
        case FCTypeObject32
        case FCTypeURL
        case FCTypePoint
        case FCTypeSize
        case FCTypeRect
        case FCTypeRange
        case FCTypeVector
        case FCTypeAffineTransform
        case FCType3DTransform
        case FCTypeMutableIndexSet
        case FCTypeIndexSet
        case FCTypeNSCodedObject
        case FCTypeDecimalNumber
        case FCTypeOne
        case FCTypeZero
        case FCTypeCount // sentinel value
}

func ==(lhs: ClassDefinition, rhs: ClassDefinition) -> Bool {
     return lhs.className == rhs.className
}


// TODO is there a something already in SWIFT?
internal class ClassDefinition : Hashable, Equatable {
    
    var className : String
    
    init(className : String) {
        self.className = className
    }
    
    var hashValue: Int {
        get {
            return className.hash
        }
    }
    

}

typealias Index = Int

public class DataCoder {
    
    public static func  dataWithRootObject(object : NSObject) -> NSData? {
        
        var output : NSMutableData! = NSMutableData(length: 0) // TODO: define default size
        
        //object count placeholders
        DCWriteUInt32(0, output: output)
        DCWriteUInt32(0, output: output)
        DCWriteUInt32(0, output: output)
        
        // Key is a object, values are the related index
        var objectCache = Dictionary<NSObject,Index>()
        
        // Key is a class, value is the related index
        var classCache = Dictionary<ClassDefinition, Index>()
        
        // Key is a string, value is the related index
        var stringCache = Dictionary<String,Index>()
        
        // Key is the class name, value is the ClassDefinition
        var classesByName = Dictionary<String,ClassDefinition>()
        
        //create coder
        
        var coder = DCCoder()
        coder.rootObject = object
        coder.output = output
        coder.objectCache = objectCache
        coder.classCache = classCache
        coder.stringCache = stringCache
        coder.classesByName  = classesByName
        
        //write object
        DCWriteObject(object, coder: coder)
        
        // no spport for FC_DIAGNOSTIC_ENABLED
        
        //set object count
        var objectCount = UInt32(objectCache.count)
        let range1 = NSMakeRange(0, sizeof(UInt32))
        output.replaceBytesInRange(range1, withBytes: &objectCount)
        
        //set class count
        var classCount = UInt32(classCache.count)
        let range2 = NSMakeRange(sizeof(UInt32), sizeof(UInt32))
        output.replaceBytesInRange(range2, withBytes: &classCount)
        
        //set string count
        var stringCount = UInt32(stringCache.count)
        let range3 = NSMakeRange(sizeof(UInt32) * 2, sizeof(UInt32))
        output.replaceBytesInRange(range3, withBytes: &stringCount)

        return output
        
    }
    
    public static func objectWithData(data : NSData) -> NSObject? {
        var output : NSObject? = nil
    
    
        return output
    }
    
    
    // MARK: Write Methode
    
    static func DCWriteBool(value: Bool, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Bool))
    }
    
    // Int8
    static func DCWriteInt8(value: Int8, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int8))
    }
    
    // Unit8
    static func DCWriteUInt8(value: UInt8, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt8))
    }
    
    // Int16
    static func DCWriteInt16(value: Int16, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int16))
    }
    
    // UInt16
    static func DCWriteUInt16(value: UInt16, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt16))
    }
    
    // Int32
    static func DCWriteInt32(value: Int32, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int32))
    }
    
    // UInt32
    static func DCWriteUInt32(value: UInt32, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt32))
    }
    
    // Int64
    static func DCWriteInt64(value: Int64, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int64))
    }
    
    // UInt64
    static func DCWriteUInt64(value: UInt64, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt64))
    }
    
    /**
    static func DCWriteInt(inout value: Int, inout output : NSMutableData) {
        
        //var data  = value
        output.appendBytes(&value, length:sizeof(Int64))
    }
    */
    
    static func DCWriteFloat(value: Float, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Float))
    }
    
    static func DCWriteDouble(value: Double, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Double))
    }
    
    static func DCWriteString(string : String, output : NSMutableData) {
        let dataUTF8 : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        output .appendData(dataUTF8)
    }
    
    static func DCWriteType(value: FCType, output : NSMutableData)
    {
      DCWriteUInt8(value.rawValue, output: output)
     //[output appendBytes:&value length:sizeof(value)];
    }
    
    static func DCWriteObject(object: NSObject?, coder : DCCoder) {
        
        if object != nil {
            object!.DC_encodeWithCoder(coder)
        } else {
            DataCoder.DCWriteType(.FCTypeNil, output: coder.output)
        }
    }
    
    static func DCAlignOutput(size : Int, output : NSMutableData) {
        var algin = output.length % size
        if algin > 0 {
            output.increaseLengthBy(size - algin)
        }
    }

    
    static func DCWriteObjectAlias(object : NSObject, coder : DCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        var index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                DCWriteType(.FCTypeObjectAlias8, output: coder.output)
                DCWriteUInt8(UInt8(index!), output: coder.output)
                return true
            case max8...max16:
                DCWriteType(.FCTypeObjectAlias16, output: coder.output)
                DCAlignOutput(sizeof(UInt16), output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                DCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                DCWriteType(.FCTypeObjectAlias32, output: coder.output)
                DCAlignOutput(sizeof(UInt32), output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
                DCWriteUInt32(UInt32(index!), output:coder.output)
                return true
            }
        }
        
        return false
    }
    
    static func DCWriteStringAlias(object : NSObject, coder : DCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        var index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                DCWriteType(.FCTypeStringAlias8, output: coder.output)
                DCWriteUInt8(UInt8(index!), output: coder.output)
            case max8...max16:
                DCWriteType(.FCTypeStringAlias16, output: coder.output)
                DCAlignOutput(sizeof(UInt16), output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                DCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                DCWriteType(.FCTypeStringAlias32, output: coder.output)
                DCAlignOutput(sizeof(UInt32), output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
                DCWriteUInt32(UInt32(index!), output:coder.output)
                return true
            
            }
        }
        
        return false

    }
}

// --------------------------------------------------------------------------------

extension NSObject {
    
    private func DC_encodeWithCoder(aCoder: DCCoder) {
        // TODO
        
        if DataCoder.DCWriteObjectAlias(self, coder: aCoder) {
            return
        }
        
        //handle NSCoding
        //not support for "preferFastCoding"
        
        if self is NSCoding {
            DataCoder.DCWriteType(.FCTypeNSCodedObject, output: aCoder.output)
            DataCoder.DCWriteObject(NSStringFromClass(self.classForCoder), coder: aCoder)
            (self as! NSCoding).encodeWithCoder(aCoder)
            DataCoder.DCWriteType(.FCTypeNil, output: aCoder.output)
            aCoder.FCCacheWrittenObject(self)
            
        } else {
            //let className = toString(self).componentsSeparatedByString(".").last!
            assertionFailure("Class \"\(self)\" don't support NSCodings")
        }
    }
    
}

// --------------------------------------------------------------------------------

class DCCoder : NSCoder {

    var rootObject : NSObject! = nil
    var output : NSMutableData! = nil
    var objectCache : Dictionary<NSObject,Index>! = nil
    var classCache : Dictionary<ClassDefinition, Index>! = nil
    var stringCache : Dictionary<String,Index>! = nil
    var classesByName : Dictionary<String,ClassDefinition>! = nil
    
    final func FCCacheWrittenObject(object : NSObject) -> Int {
        
        let count = objectCache.count
        objectCache[object] = count + 1
        return count
    }
    
    // no impelemtation for FCIndexOfCachedObject required
}

class DCDecoder : NSCoder {
    
    var offset : UInt64 = 0
    // const void *_input
    var total : UInt64 = 0
    
    var objectCache : NSData! = nil
    var classCache : NSData! = nil
    var stringCache : NSData! = nil
    
    //FCTypeConstructor **_constructors;
    //__unsafe_unretained NSData *_objectCache;
    //__unsafe_unretained NSData *_classCache;
    //__unsafe_unretained NSData *_stringCache;
    //__unsafe_unretained NSMutableArray *_propertyDictionaryPool;
    //__unsafe_unretained NSMutableDictionary *_properties;
    
}