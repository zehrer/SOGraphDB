//
//  DataCoder.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

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
        
        // NO FC_DIAGNOSTIC_ENABLED
        
        //set object count
        var objectCount = objectCache.count
        // [output replaceBytesInRange:NSMakeRange(sizeof(header), sizeof(uint32_t)) withBytes:&objectCount];
        
        //set class count
        var classCount = classCache.count
        //[output replaceBytesInRange:NSMakeRange(sizeof(header) + sizeof(uint32_t), sizeof(uint32_t)) withBytes:&classCount];
        
        //set string count
        var stringCount = stringCache.count
        //[output replaceBytesInRange:NSMakeRange(sizeof(header) + sizeof(uint32_t) * 2, sizeof(uint32_t)) withBytes:&stringCount];

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
    
    static func DCWriteObject(object: NSObject?, coder : DCCoder) {
        
        if object != nil {
            object!.DC_encodeWithCoder(coder)
        } else {
            // TODO: implement FCWriteType
            // FCWriteType(FCTypeNil, coder->_output);
        }
    }
    
    
}

// --------------------------------------------------------------------------------


func DCWriteObjectAlias( object : NSObject, coder : DCCoder) -> Bool {
    
    let max8 = Int(UInt8.max)
    let max16 = Int(UInt16.max)
    
    var index = coder.objectCache[object]
    
    if index != nil {
        switch index! {
        case 0...max8:
            //FCWriteType(FCTypeObjectAlias8, coder->_output);
            //FCWriteUInt8((uint8_t)index, coder->_output);
            return true
        case max8...max16:
            //FCWriteType(FCTypeObjectAlias16, coder->_output);
            //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
            //FCWriteUInt16((uint16_t)index, coder->_output);
            return true
        default:
            //FCWriteType(FCTypeObjectAlias32, coder->_output);
            //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
            //FCWriteUInt32((uint32_t)index, coder->_output);
            return true
        }
    }
    
    return false
}


    

// --------------------------------------------------------------------------------

extension NSObject {
    
    private func DC_encodeWithCoder(aCoder: DCCoder) {
        // TODO
        
        if DCWriteObjectAlias(self, aCoder) {
            return
        }
        
    }
        //handle NSCoding
        
        /**
        if (![self preferFastCoding] && [self conformsToProtocol:@protocol(NSCoding)])
        {
            //write object
            FCWriteType(FCTypeNSCodedObject, coder->_output);
            FCWriteObject(NSStringFromClass([self classForCoder]), coder);
            [(id <NSCoding>)self encodeWithCoder:coder];
            FCWriteType(FCTypeNil, coder->_output);
            FCCacheWrittenObject(self, coder->_objectCache);
            return;
        }
    }
*/
    
}

// --------------------------------------------------------------------------------

class DCCoder : NSCoder {

    var rootObject : NSObject! = nil
    var output : NSMutableData! = nil
    var objectCache : Dictionary<NSObject,Index>! = nil
    var classCache : Dictionary<ClassDefinition, Index>! = nil
    var stringCache : Dictionary<String,Index>! = nil
    var classesByName : Dictionary<String,ClassDefinition>! = nil

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