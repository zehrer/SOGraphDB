//
//  FastCoding.swift
//
//  Version 0.83
//
//  Created by Stephan Zehrer 04/21/2015
//  Copyright (c) 2015 Stephan Zehrer
//  Obj-C Version created by Nick Lockwood on 09/12/2013.
//
// This is a port of the the Obj-C libray/classes FastCoding to SWIFT 1.2
// https://github.com/nicklockwood/FastCoding
// Baseline of this port was version 3.2.1 of FastCoding
//
//  !!! INFO !!!
//  This port cover not 100% of the FastCoding features, the following features are supported at the moment:
//  - Replace as the NSKeyedArchiver / NSKeyedUnarchiver (TEST: TODO)
//  - NSString
//  - Int & UInt (8,16,32,64) and Float / Double
//  - NSNumber (inc. UInt64 which seems not covered in the ObjC version)
//  - NSArray (decode always to NSMutableArray)
//  - support for NSData & NSMutableData
//  - NSDate
//
//  This port do NOT support at the moment:
//  - same binary format as FastCoder ObjC
//  - The FastCoding "protocol"
//  - support for older major versions (2_3 methodes)
//  - NSCoder.encodeConditionalObject (the implementation in FastCoder ObjC is not correct too)
//  - Complex object cycles obj1 <-> obj2 (the implementation of on FastCoder ObjC is not correct too)
//  - support "propertyListWithData"
//  - support for NSDictionary / NSMutableDictionary
//  - support for NSSet / NSSetOrderedSet
//  - support for NSMutableString
//  - support for NSURL
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/zehrer/FastCoding
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import Foundation

//static const uint32_t FCIdentifier = 'FAST';

// This port is based on the 3.2.1 Version of FastEncode
// TODO: add header support

let FCIdentifier   : UInt32 = 1178686292 //  'FAST';
let FCMajorVersion : UInt16 = 3
let FCMinorVersion : UInt16 = 2

struct FCHeader {
    let identifier   : UInt32 = 0
    let majorVersion : UInt16 = 0
    let minorVersion : UInt16 = 0
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

extension NSData {
    
    /**
    func stringDataLength(offset : Int = 0) -> UInt {
        var utf8 = UnsafePointer<Int8>(self.bytes + offset)
        return strlen(utf8) + 1 // +1 for zero termination
    }
    */
    
    func decodeStringData() -> String? {
        return String.fromCString(UnsafePointer<CChar>(self.bytes))
    }
}

extension NSMutableData {
    
    func appendEncodedString(string: NSString) {
        // encode with "dataUsingEncoding"
        var zero : UInt8 = 0
        
        //var mutableData = NSMutableData()
        
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        
        if data != nil {
            self.appendData(data!)
        }
        
        // write zero termination
        self.appendBytes(&zero, length: sizeof(UInt8))

    }
}

typealias Index = Int

public class FastCoder {
    
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
        case FCTypeUInt8
        case FCTypeUInt16
        case FCTypeUInt32
        case FCTypeUInt64
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
        case FCTypeEnd  // mark a end (e.g. end of a list)
        
        case FCTypeUnknown // renamed FCTypeCount (entinel value)
    }

    
    // write data
    public static func dataWithRootObject(object : NSObject) -> NSData? {
        
        let output : NSMutableData! = NSMutableData(length: 0) // TODO: define default size
        
        //object count placeholders
        //FCWriteUInt32(16, output: output)
        //FCWriteUInt32(0, output: output)
        //FCWriteUInt32(0, output: output)
        
        // Key is a object, values are the related index
        let objectCache = Dictionary<NSObject,Index>()
        
        // Key is a class, value is the related index
        let classCache = Dictionary<ClassDefinition, Index>()
        
        // Key is a string, value is the related index
        let stringCache = Dictionary<String,Index>()
        
        // Key is the class name, value is the ClassDefinition
        let classesByName = Dictionary<String,ClassDefinition>()
        
        //create coder
        
        let coder = FCCoder()
        coder.rootObject = object
        coder.output = output
        coder.objectCache = objectCache
        coder.classCache = classCache
        coder.stringCache = stringCache
        coder.classesByName  = classesByName
        
        //write object
        FCWriteObject(object, coder: coder)
        
        // no spport for FC_DIAGNOSTIC_ENABLED
        
        //set object count
        //var objectCount = UInt32(objectCache.count)
        //let range1 = NSMakeRange(0, sizeof(UInt32))
        //output.replaceBytesInRange(range1, withBytes: &objectCount)
        
        //set class count
        //var classCount = UInt32(classCache.count)
        //let range2 = NSMakeRange(sizeof(UInt32), sizeof(UInt32))
        //output.replaceBytesInRange(range2, withBytes: &classCount)
        
        //set string count
        //var stringCount = UInt32(stringCache.count)
        //let range3 = NSMakeRange(sizeof(UInt32) * 2, sizeof(UInt32))
        //output.replaceBytesInRange(range3, withBytes: &stringCount)

        return output
        
    }
    
    // read data
    public static func objectWithData(data: NSData) -> NSObject? {
        // TODO: FCTypeConstructor *constructors[]
        
        //let length = data.length
        //let offset = 0 // sizeof(FCHeader)

        /**
        if length < sizeof(FCHeader) {
            //not a valid FastArchive
            return nil
        }

        var header = FCHeader()
        data.getBytes(&header,length: sizeof(FCHeader))
        if (header.identifier != FCIdentifier) { return nil }
        if (header.majorVersion < 2 || header.majorVersion > FCMajorVersion) {
            NSLog("This version of the FastCoding library doesn't support FastCoding version %i.%i files", header.majorVersion, header.minorVersion)
            return nil
        }
        
        */
        
        let decoder = FCDecoder(data: data)
        //decoder.total = length
        
        // objectCache
        //let objectCacheInitCapacity = Int(FCReadRawUInt32(decoder))
        //decoder.objectCache = NSMutableData(capacity: objectCacheInitCapacity)
        
        
        // NO SUPPORT FOR OLDER FILES
        
        // classCache
        //let classCacheInitCapacity = Int(FCReadRawUInt32(decoder))
        //decoder.classCache = NSMutableData(capacity: classCacheInitCapacity)
        
        // stringCache
        //let stringCacheInitCapacity = Int(FCReadRawUInt32(decoder))
        //decoder.stringCache = NSMutableData(capacity: stringCacheInitCapacity)

        
        //__autoreleasing NSMutableArray *propertyDictionaryPool = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
        //decoder->_propertyDictionaryPool = propertyDictionaryPool;
        
        // NO DIAGNOSTIC
    
        return FCReadObject(decoder)
    }
    
    // MARK: Read Methode
    
    static func FCReadValue<T>(inout value:T, decoder: FCDecoder) {
        let size = sizeof(T)
        let data = decoder.getDataSection(size)
        data.getBytes(&value, length:size)
    }
    
    static func FCReadType(decoder : FCDecoder) -> FCType {
        
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        
        let type = FCType(rawValue: value)
        
        if type != nil  {
            return type!
        }
        
        return .FCTypeUnknown
    }
    
    static func FCReadRawUInt8(decoder : FCDecoder) -> UInt8 {
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawUInt16(decoder : FCDecoder) -> UInt16 {

        var value : UInt16 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawUInt32(decoder : FCDecoder) -> UInt32 {
        
        var value : UInt32 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawString(decoder : FCDecoder) -> String? {
        
        // get the data size of the string
        let stringLength = decoder.stringDataLength() // data.stringDataLength(offset: decoder.location)
        let stringData = decoder.getDataSection(Int(stringLength))
        
        if stringLength > 1 {
        
            return stringData.decodeStringData()
        }
        
        return ""
    }
    
    static func FCReadAlias8(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt8(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadAlias16(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt16(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadAlias32(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt32(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadStringAlias8(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt8(decoder)
        
        return decoder.stringCache[Int(index)]
    }
    
    static func FCReadStringAlias16(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt16(decoder)
        
        return decoder.stringCache[Int(index)]
    }
    
    static func FCReadStringAlias32(decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt32(decoder)
        
        return decoder.stringCache[Int(index)]
    }
    
    static func FCReadString(decoder : FCDecoder) -> String {
        let string = FCReadRawString(decoder)

        if string != nil {
            decoder.stringCache.append(string!)
            return string!
        }
        
        assertionFailure("ReadRaw should never return a nil string")
        return ""
    }
    
    static func FCReadMutableString(decoder : FCDecoder) -> String {
        
        assertionFailure("No support for MutableString")
        return ""
    }
    
    static func FCReadArray(decoder : FCDecoder) -> NSMutableArray {
        
        let result = NSMutableArray()
        
        while (true) {
            
            let type = FCReadType(decoder)
            
            if type == .FCTypeEnd {
                break;
            }
            
            let object = FCReadObject(type, decoder: decoder)
            if object != nil {
                 result.addObject(object!)
            }
        }
        
        decoder.objectCache.append(result)
        
        return result
    }
    
/**
static id FCReadArray(__unsafe_unretained FCNSDecoder *decoder)
{
    FC_ALIGN_INPUT(uint32_t, *decoder->_offset);
    uint32_t count = FCReadRawUInt32(decoder);
    __autoreleasing NSArray *array = nil;
    if (count)
    {
        __autoreleasing id *objects = (__autoreleasing id *)malloc(count * sizeof(id));
        for (uint32_t i = 0; i < count; i++)
        {
            objects[i] = FCReadObject(decoder);
        }
        array = [NSArray arrayWithObjects:objects count:count];
        free(objects);
    }
    else
    {
        array = @[];
    }
    FCCacheParsedObject(array, decoder->_objectCache);
    return array;
}

*/


    static func FCReadNSCodedObject(decoder : FCDecoder) -> NSObject? {
        
        let className = FCReadObject(decoder) as! String
        let oldProperties = decoder.properties
        
        decoder.properties = Dictionary()
        
        while (true) {
            // read all elements as input for initWithCoder:
            let type = FCReadType(decoder)
            
            if type == .FCTypeEnd {
                break;
            } // list termination
            
            let object = FCReadObject(type, decoder: decoder)
            let key = FCReadObject(decoder) as! String
            decoder.properties[key] = object
        }
        
        //let objClass = NSClassFromString(className) as! NSCoding.Type
        // it seems this code lead to a segmentation fault in the compiler
        //var object : NSObject = objClass(coder: decoder) as! NSObject
        
        //let objClass: AnyClass! = NSClassFromString(className)
        //let codingClass = objClass as! NSCoding.Type
        //var object = codingClass.init(coder: decoder)
        
        let object = ObjCHelper.initClass(className, withCoder: decoder)
        
        decoder.objectCache.append(object)
        
        decoder.properties = oldProperties
        
        return object //object
    }
    

    /**
    
    static func FCReadNSCodedObject(decoder : FCDecoder) -> NSObject? {
        
        var className = FCReadObject(decoder) as! String
        var oldProperties = decoder.properties
    
        if (decoder.propertyDictionaryPool.count > 0) {
            decoder.properties = decoder.propertyDictionaryPool.last!
            decoder.propertyDictionaryPool.removeLast()
            decoder.properties.removeAll(keepCapacity: true)
        } else {
            decoder.properties = Dictionary()
        }
    
        while (true) {
            // read all elements as input for initWithCoder:
            var object = FCReadObject(decoder)
            if object != nil { break }
            var key = FCReadObject(decoder)as! String
            decoder.properties[key] = object
        }
        
        let objClass = NSClassFromString(className) as! NSCoding.Type
    
        var object = objClass(coder: decoder)
        decoder.propertyDictionaryPool.append(decoder.properties)
        decoder.properties = oldProperties
        
        return object as? NSObject
    }

    */


    
/**
static id FCReadInt8(__unsafe_unretained FCNSDecoder *decoder)
{
    FC_READ_VALUE(int8_t, *decoder->_offset, decoder->_input, decoder->_total);
    __autoreleasing NSNumber *number = @(value);
    return number;
}
*/
    
    static func FCReadInt8(decoder : FCDecoder) -> Int8 {
        var value : Int8 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt8(decoder : FCDecoder) -> UInt8 {
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }

    static func FCReadInt16(decoder : FCDecoder) -> Int16 {
        var value : Int16 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt16(decoder : FCDecoder) -> UInt16 {
        var value : UInt16 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }

    static func FCReadInt32(decoder : FCDecoder) -> Int32 {
        var value : Int32 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt32(decoder : FCDecoder) -> UInt32 {
        var value : UInt32 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadInt64(decoder : FCDecoder) -> Int64 {
        var value : Int64 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt64(decoder : FCDecoder) -> UInt64 {
        var value : UInt64 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadFloat32(decoder : FCDecoder) -> Float32 {
        var value : Float32 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadFloat64(decoder : FCDecoder) -> Double {
        var value : Double = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawData(decoder : FCDecoder) -> NSData {
        
        let length = FCReadUInt32(decoder)
        return decoder.getDataSection(Int(length))
    }
    
    
    static func FCReadData(decoder : FCDecoder) -> NSData {
        let data = FCReadRawData(decoder)
        
        decoder.objectCache.append(data)
        
        return data
    }
    
    static func FCReadMutableData(decoder : FCDecoder) -> NSMutableData {
        let temp = FCReadRawData(decoder)
        
        let data = NSMutableData(data: temp)
        
        decoder.objectCache.append(data)
        
        return data
    }
    
    static func FCReadDate(decoder : FCDecoder) -> NSDate {
        var value : NSTimeInterval = 0
        FCReadValue(&value, decoder: decoder)
        
        let date = NSDate(timeIntervalSince1970: value)
        decoder.objectCache.append(date)
        
        return date
    }
    
/**
static id FCReadDate(__unsafe_unretained FCNSDecoder *decoder)
{
    FC_ALIGN_INPUT(NSTimeInterval, *decoder->_offset);
    FC_READ_VALUE(NSTimeInterval, *decoder->_offset, decoder->_input, decoder->_total);
    __autoreleasing NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
    FCCacheParsedObject(date, decoder->_objectCache);
    return date;
}
*/
    
    static func FCReadObject(decoder : FCDecoder) -> NSObject? {
        let type = FCReadType(decoder)

        return FCReadObject(type, decoder: decoder)

    }
    
    static func FCReadObject(type: FCType, decoder : FCDecoder) -> NSObject? {
        
        switch type {
        case .FCTypeNil:
            return nil
        case .FCTypeNull:
            return NSNull()
        case .FCTypeObjectAlias8:
            return FCReadAlias8(decoder)
        case .FCTypeObjectAlias16:
            return FCReadAlias16(decoder)
        case .FCTypeObjectAlias32:
            return FCReadAlias32(decoder)
        case .FCTypeStringAlias8:
            return FCReadStringAlias8(decoder)
        case .FCTypeStringAlias16:
            return FCReadStringAlias16(decoder)
        case .FCTypeStringAlias32:
            return FCReadStringAlias32(decoder)
        case .FCTypeString:
            return FCReadString(decoder)
        //case .FCTypeDictionary:
        case .FCTypeArray:
            return FCReadArray(decoder)
        case .FCTypeTrue:
            return true
        case .FCTypeFalse:
            return false
        case .FCTypeInt8:
            return NSNumber(char: FCReadInt8(decoder))
        case .FCTypeUInt8:
            return NSNumber(unsignedChar:FCReadUInt8(decoder))
        case .FCTypeInt16:
            return NSNumber(short: FCReadInt16(decoder))
        case .FCTypeUInt16:
            return NSNumber(unsignedShort: FCReadUInt16(decoder))
        case .FCTypeInt32:
            return NSNumber(int: FCReadInt32(decoder))
        case .FCTypeUInt32:
            return NSNumber(unsignedInt: FCReadUInt32(decoder))
        case .FCTypeInt64:
            return NSNumber(longLong: FCReadInt64(decoder))
        case .FCTypeUInt64:
            return NSNumber(unsignedLongLong: FCReadUInt64(decoder))
        case .FCTypeFloat32:
            return FCReadFloat32(decoder)
        case .FCTypeFloat64:
            return FCReadFloat64(decoder)
        case .FCTypeData:
            return FCReadData(decoder)
        case .FCTypeMutableData:
            return FCReadMutableData(decoder)
        case .FCTypeDate:
            return FCReadDate(decoder)
        case .FCTypeNSCodedObject:
            return FCReadNSCodedObject(decoder)
        case .FCTypeOne:
            return 1
        case .FCTypeZero:
            return 0
        case .FCTypeUnknown:
            assertionFailure("Error during encoding, unknown type found")
        default:
            assertionFailure("Not supported type")
            
        }
        
        return nil

//            case FCTypeDictionary
//            case FCTypeArray
//            case FCTypeSet
//            case FCTypeOrderedSet
//            case FCTypeData
//            case FCTypeDate
//            case FCTypeMutableString
//            case FCTypeMutableDictionary
//            case FCTypeMutableArray
//            case FCTypeMutableSet
//            case FCTypeMutableOrderedSet
//            case FCTypeMutableData
//            case FCTypeClassDefinition
//            case FCTypeObject8
//            case FCTypeObject16
//            case FCTypeObject32
//            case FCTypeURL
//            case FCTypePoint
//            case FCTypeSize
//            case FCTypeRect
//            case FCTypeRange
//            case FCTypeVector
//            case FCTypeAffineTransform
//            case FCType3DTransform
//            case FCTypeMutableIndexSet
//            case FCTypeIndexSet
//            case FCTypeDecimalNumber
//            case FCTypeEndProperty
//            case FCTypeCount // sentinel value
        
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: Write Methode

/**
    static func FCWriteBool(value: Bool, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Bool))
    }
*/
    
    // Int8
    static func FCWriteInt8(value: Int8, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int8))
    }
    
    // Unit8
    static func FCWriteUInt8(value: UInt8, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt8))
    }
    
    // Int16
    static func FCWriteInt16(value: Int16, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int16))
    }
    
    // UInt16
    static func FCWriteUInt16(value: UInt16, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt16))
    }
    
    // Int32
    static func FCWriteInt32(value: Int32, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int32))
    }
    
    // UInt32
    static func FCWriteUInt32(value: UInt32, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt32))
    }
    
    // Int64
    static func FCWriteInt64(value: Int64, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Int64))
    }
    
    // UInt64
    static func FCWriteUInt64(value: UInt64, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(UInt64))
    }
    
    static func FCWriteFloat(value: Float, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Float))
    }
    
    static func FCWriteDouble(value: Double, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Double))
    }
    
    static func FCWriteString(string : NSString, output : NSMutableData) {
        output.appendEncodedString(string)
        
        //let dataUTF8 : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        //output .appendData(dataUTF8)
    }
    
    static func FCWriteType(value: FCType, output : NSMutableData)
    {
      FCWriteUInt8(value.rawValue, output: output)
     //[output appendBytes:&value length:sizeof(value)];
    }
    
    static func FCWriteObject(object: AnyObject?, coder : FCCoder) {
        
        if object != nil {
            if object is NSObject {
                (object! as! NSObject).FC_encodeWithCoder(coder)
            } else {
                assertionFailure("Object \"\(self)\" is not a NSObject")
            }
        } else {
            FastCoder.FCWriteType(.FCTypeNil, output: coder.output)
        }
    }
    
    static func FCAlignOutput(size : Int, output : NSMutableData) {
        let algin = output.length % size
        if algin > 0 {
            output.increaseLengthBy(size - algin)
        }
    }

    
    static func FCWriteObjectAlias(object : NSObject, coder : FCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        let index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                FCWriteType(.FCTypeObjectAlias8, output: coder.output)
                FCWriteUInt8(UInt8(index!), output: coder.output)
                return true
            case max8...max16:
                FCWriteType(.FCTypeObjectAlias16, output: coder.output)
                FCAlignOutput(sizeof(UInt16), output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                FCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                FCWriteType(.FCTypeObjectAlias32, output: coder.output)
                FCAlignOutput(sizeof(UInt32), output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
                FCWriteUInt32(UInt32(index!), output:coder.output)
                return true
            }
        }
        
        return false
    }
    
    static func FCWriteStringAlias(object : NSObject, coder : FCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        let index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                FCWriteType(.FCTypeStringAlias8, output: coder.output)
                FCWriteUInt8(UInt8(index!), output: coder.output)
            case max8...max16:
                FCWriteType(.FCTypeStringAlias16, output: coder.output)
                FCAlignOutput(sizeof(UInt16), output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                FCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                FCWriteType(.FCTypeStringAlias32, output: coder.output)
                FCAlignOutput(sizeof(UInt32), output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
                FCWriteUInt32(UInt32(index!), output:coder.output)
                return true
            
            }
        }
        
        return false

    }
    
}

// --------------------------------------------------------------------------------

extension NSObject {
    
    
    // Encode the following elements:
    // - Type:FCTypeNSCodedObject
    // - ClassName as String
    // - call "encodeWithCoder"
    // - NIL (Why? as termination?)
    @objc public func FC_encodeWithCoder(aCoder: FCCoder) {
        // TODO
        
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        
        //handle NSCoding
        //not support for "preferFastCoding"
        
        if let object = self as? NSCoding {
            // write type and class name
            FastCoder.FCWriteType(.FCTypeNSCodedObject, output: aCoder.output)
            FastCoder.FCWriteObject(NSStringFromClass(self.classForCoder), coder: aCoder)
            
            // encode all elements of the obj
            object.encodeWithCoder(aCoder)
            
            // put it in the "after" encodeWithCoder call cache
            aCoder.FCCacheWrittenObject(self)
            
            // write end signal
            FastCoder.FCWriteType(.FCTypeEnd, output: aCoder.output)
        } else {
            //let className = toString(self).componentsSeparatedByString(".").last!
            assertionFailure("Class \"\(self)\" don't support NSCodings")
        }
    }
    
}


extension NSString {

    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        
        // It seems even NSStringFromClass return a NSMutableString
//        if self is NSMutableString   {
//            // encode as object (why?)
//            if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
//            aCoder.FCCacheWrittenObject(self)
//            FastCoder.FCWriteType(.FCTypeMutableString, output:aCoder.output)
//        } else {

            // encode as string
            if FastCoder.FCWriteStringAlias(self, coder: aCoder) { return }
            aCoder.FCCacheWrittenString(self)
            FastCoder.FCWriteType(.FCTypeString, output:aCoder.output)
//        }
        
        FastCoder.FCWriteString(self, output: aCoder.output)
    }
}

extension NSNumber {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        
        //let type = CFNumberGetType(self as CFNumberRef)
        
        let type  = String.fromCString(self.objCType)!

        switch type {
        case "f": //.FloatType, .Float32Type:
            FastCoder.FCWriteType(.FCTypeFloat32, output:aCoder.output)
            var value = self.floatValue
            //FC_ALIGN_OUTPUT(Float32, coder->_output);
            aCoder.output.appendBytes(&value, length:sizeof(Float))
            
        case "d": //.DoubleType, .CGFloatType, .Float64Type:
            FastCoder.FCWriteType(.FCTypeFloat64, output:aCoder.output)
            var value = self.doubleValue
            //FC_ALIGN_OUTPUT(Float64, coder->_output);
            aCoder.output.appendBytes(&value, length:sizeof(Double))
            
        case "Q":
            var value = self.unsignedLongLongValue
            if  value > UInt64(UInt32.max) {
                FastCoder.FCWriteType(.FCTypeUInt64, output:aCoder.output)
                aCoder.output.appendBytes(&value, length:sizeof(UInt64))
            } else {
                fallthrough
            }
        case "L":
            var value = self.unsignedIntValue
            if  value > UInt32(UInt16.max) {
                FastCoder.FCWriteType(.FCTypeUInt32, output:aCoder.output)
                aCoder.output.appendBytes(&value, length:sizeof(UInt32))
            } else {
                fallthrough
            }
        case "S":
            var value = self.unsignedShortValue
            if  value > UInt16(UInt8.max) {
                FastCoder.FCWriteType(.FCTypeUInt16, output:aCoder.output)
                aCoder.output.appendBytes(&value, length:sizeof(UInt16))
            } else {
                fallthrough
            }
        case "C":
            var value = self.unsignedCharValue
            FastCoder.FCWriteType(.FCTypeUInt8, output:aCoder.output)
            aCoder.output.appendBytes(&value, length:sizeof(UInt8))
        case "q": //.SInt64Type, .LongLongType, .NSIntegerType:
            var value = self.longLongValue
            if (value > Int64(Int32.max)) || (value < Int64(Int32.min)) {
                FastCoder.FCWriteType(.FCTypeInt64, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int64_t, coder->_output);
                aCoder.output.appendBytes(&value, length:sizeof(Int64))
            } else {
                fallthrough
            }
        case "i", "l": //.SInt32Type, .IntType, .LongType, .CFIndexType:
            var value = self.intValue
            if (value > Int32(Int16.max)) || (value < Int32(Int16.min)) {
                FastCoder.FCWriteType(.FCTypeInt32, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int32_t, coder->_output);
                aCoder.output.appendBytes(&value, length:sizeof(Int32))
            } else {
                fallthrough
            }

        case "s" : //.SInt16Type, .ShortType:
            var value = self.shortValue
            if (value > Int16(Int8.max)) || (value < Int16(Int8.min)) {
                FastCoder.FCWriteType(.FCTypeInt16, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int16_t, coder->_output);
                aCoder.output.appendBytes(&value, length:sizeof(Int16))
            } else {
                fallthrough
            }
        case "c": //.SInt8Type, .CharType:
            var value = self.charValue
            switch value {
            case 1:
                if self == kCFBooleanTrue {
                    FastCoder.FCWriteType(.FCTypeTrue, output:aCoder.output)
                } else  {
                    FastCoder.FCWriteType(.FCTypeOne, output:aCoder.output)
                }
                    
            case 0:
                if self == kCFBooleanTrue {
                    FastCoder.FCWriteType(.FCTypeFalse, output:aCoder.output)
                } else {
                    FastCoder.FCWriteType(.FCTypeZero, output:aCoder.output)
                }
            default:
                FastCoder.FCWriteType(.FCTypeInt8, output:aCoder.output)
                aCoder.output.appendBytes(&value, length:sizeof(Int8))
            }
        default:
            assertionFailure("Unhandeld type")
        }

    }
}

extension NSDecimalNumber {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSDate {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        aCoder.FCCacheWrittenObject(self)
        FastCoder.FCWriteType(.FCTypeDate, output:aCoder.output)
        
        var value = self.timeIntervalSince1970
        aCoder.output.appendBytes(&value, length:sizeof(NSTimeInterval))
    }
}

/**
- (void)FC_encodeWithCoder:(__unsafe_unretained FCNSCoder *)coder
{


    NSTimeInterval value = [self timeIntervalSince1970];
    FC_ALIGN_OUTPUT(NSTimeInterval, coder->_output);
    [coder->_output appendBytes:&value length:sizeof(value)];
}
*/

extension NSData {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        aCoder.FCCacheWrittenObject(self)
        
        if self is NSMutableData {
            FastCoder.FCWriteType(.FCTypeMutableData, output:aCoder.output)
        } else {
            FastCoder.FCWriteType(.FCTypeData, output:aCoder.output)
        }
        
        FastCoder.FCWriteUInt32(UInt32(length), output:aCoder.output)
        aCoder.output.appendData(self)
    }
}

/**
    FC_ALIGN_OUTPUT(uint32_t, coder->_output);
    coder->_output.length += (4 - ((length % 4) ?: 4));
*/

extension NSNull {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
        //FastCoder.FCWriteType(.FCTypeNull, output:aCoder.output)
    }
}

extension NSDictionary {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}


extension NSArray {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        
        //var mutable = self is NSMutableArray
        
        FastCoder.FCWriteType(.FCTypeArray, output:aCoder.output)
        
        for item in self {
            FastCoder.FCWriteObject(item, coder: aCoder)
        }
        
        FastCoder.FCWriteType(.FCTypeEnd, output:aCoder.output)
        
        aCoder.FCCacheWrittenObject(self)

    }

}

extension NSSet {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSOrderedSet {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSIndexSet {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSURL {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        if FastCoder.FCWriteStringAlias(self, coder: aCoder) { return }
        FastCoder.FCWriteType(.FCTypeURL, output:aCoder.output);
        FastCoder.FCWriteObject(self.relativeString, coder: aCoder)
        //FCWriteObject(self.relativeString, coder);
        FastCoder.FCWriteObject(self.baseURL, coder: aCoder)
        //FCWriteObject(self.baseURL, coder);
        
        //aCoder.FCCacheWrittenString(self.)
        // TODO: is string cache here an bug?
        //FCCacheWrittenObject(self, coder->_stringCache);
    }
}

extension NSValue {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

// --------------------------------------------------------------------------------

public class FCCoder : NSCoder {

    var rootObject : NSObject! = nil
    var output : NSMutableData! = nil
    var objectCache : Dictionary<NSObject,Index>! = nil
    var classCache : Dictionary<ClassDefinition, Index>! = nil
    var stringCache : Dictionary<String,Index>! = nil
    var classesByName : Dictionary<String,ClassDefinition>! = nil
    
    final func FCCacheWrittenObject(object : NSObject) -> Int {
        // index have to start with 0, 
        //let count = objectCache.count
        objectCache[object] = objectCache.count //+ 1
        return objectCache.count
    }
    
    final func FCCacheWrittenString(string : NSString) -> Int {
        
        let count = stringCache.count
        stringCache[string as String] = count + 1
        return count
    }
    
    // no impelemtation for FCIndexOfCachedObject required
    // use: var index = coder.objectCache[object]
    
    override public var allowsKeyedCoding: Bool {
        get {
            return true
        }
    }
    
    override public func encodeObject(objv: AnyObject?, forKey key: String) {
        FastCoder.FCWriteObject(objv, coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeConditionalObject(objv: AnyObject?, forKey key: String) {
        
        // This implementation is a more or less 1:1 port of the implementation inf
        // in the objc version of FactCoder
        // According my understanding fullfill this not the NSCoder requirements
        // this method write the reference if the object was already stored
        // But what is with the case the when the object will be stored later?
        // see original code

        if let obj = objv as? NSObject {
           let index = objectCache[obj]
            
            if index != nil {
                FastCoder.FCWriteObject(objv, coder: self)
                FastCoder.FCWriteObject(key, coder: self)
            }
            
        } else {
            assertionFailure("Object \"\(self)\" is not a NSObject")
        }
    }
    
    /**
    - (void)encodeConditionalObject:(id)objv forKey:(__unsafe_unretained NSString *)key
    {
    if (FCIndexOfCachedObject(objv, _objectCache) != NSNotFound)
    {
    FCWriteObject(objv, self);
    FCWriteObject(key, self);
    }
    }
    */
    
    override public func encodeBool(boolv: Bool, forKey key: String) {
        
        if boolv {
            FastCoder.FCWriteType(.FCTypeTrue, output: output)
        } else {
            FastCoder.FCWriteType(.FCTypeFalse, output: output)
        }
        FastCoder.FCWriteObject(key, coder: self)
        
        // original
        //FastCoder.FCWriteObject(NSNumber(bool: boolv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)

    }
    
    override public func encodeInt(intv: Int32, forKey key: String) {
        FastCoder.FCWriteType(.FCTypeInt32, output: output)
        FastCoder.FCWriteInt32(intv, output: output)
        FastCoder.FCWriteObject(key, coder: self)
        
        
        // original
        //FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInt32(intv: Int32, forKey key: String) {
        FastCoder.FCWriteType(.FCTypeInt32, output: output)
        FastCoder.FCWriteInt32(intv, output: output)
        FastCoder.FCWriteObject(key, coder: self)
        
        // original
        //FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInt64(intv: Int64, forKey key: String) {
        
        FastCoder.FCWriteType(.FCTypeInt64, output: output)
        FastCoder.FCWriteInt64(intv, output: output)
        FastCoder.FCWriteObject(key, coder: self)

        // original
        //FastCoder.FCWriteObject(NSNumber(longLong: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInteger(intv: Int, forKey key: String) {
        
        if (intv > Int(Int32.max)) || (intv < Int(Int32.min)) {
            encodeInt64(Int64(intv), forKey: key)
        } else {
            encodeInt32(Int32(intv), forKey: key)
        }
        
        //FastCoder.FCWriteObject(NSNumber(long: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeFloat(realv: Float, forKey key: String) {
        FastCoder.FCWriteType(.FCTypeFloat32, output: output)
        FastCoder.FCWriteFloat(realv, output: output)
        FastCoder.FCWriteObject(key, coder: self)
        
        //FastCoder.FCWriteObject(NSNumber(float: realv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeDouble(realv: Double, forKey key: String) {
        
        FastCoder.FCWriteType(.FCTypeFloat64, output: output)
        FastCoder.FCWriteDouble(realv, output: output)
        FastCoder.FCWriteObject(key, coder: self)
        
        //FastCoder.FCWriteObject(NSNumber(double: realv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeBytes(bytesp: UnsafePointer<UInt8>, length lenv: Int, forKey key: String) {
        FastCoder.FCWriteObject(NSData(bytes: bytesp, length: lenv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }

}

class FCDecoder : NSCoder {
    
    let data : NSData
    
    init(data: NSData) {
        self.data = data
    }
    
    //var total = 0
    
    //var objectCache : NSMutableData! = nil
    var objectCache = Array<NSObject>()
    
    var classCache : NSMutableData! = nil
    
    //var stringCache : NSMutableData! = nil
    var stringCache = Array<String>()
    
    var properties = Dictionary<String,NSObject>()
    //var propertyDictionaryPool = Array<Dictionary<String,NSObject>>()
    
    // data for NSRange
    var location = 0
    func dataRange(length : Int) -> NSRange {
        let result =  NSRange(location: location, length: length)
        
        location += length
        
        return result
    }
    
    func getDataSection(length : Int) -> NSData {
        return data.subdataWithRange(dataRange(length))
    }
    
    // return string lengh at current location (incl. zero termination)
    func stringDataLength() -> UInt {
        let utf8 = UnsafePointer<Int8>(data.bytes + location)
        return strlen(utf8) + 1 // +1 for zero termination
    }
    
    /**
    - (id)decodeObjectForKey:(__unsafe_unretained NSString *)key
    {
    return _properties[key];
    }
*/
    
    // MARK: NSCoder
    
    override var allowsKeyedCoding : Bool {
        get {
            return true
        }
    }
    
    override func containsValueForKey(key: String) -> Bool {
        return properties[key] != nil
    }
    
    override func decodeObjectForKey(key: String) -> AnyObject? {
        return properties[key]
    }
    
    override func decodeBoolForKey(key: String) -> Bool {
        let result = properties[key] as! NSNumber
        return result.boolValue
    }
    
    override func decodeIntForKey(key: String) -> Int32 {
        let result = properties[key] as! NSNumber
        return result.intValue
    }
    
    override func decodeIntegerForKey(key: String) -> Int {
        let result = properties[key] as! NSNumber
        return result.integerValue
    }
    
    override func decodeInt64ForKey(key: String) -> Int64 {
        let result = properties[key] as! NSNumber
        return result.longLongValue
    }
    
    override func decodeInt32ForKey(key: String) -> Int32 {
        let result = properties[key] as! NSNumber
        return result.intValue
    }
    
    override func decodeDoubleForKey(key: String) -> Double {
        let result = properties[key] as! NSNumber
        return result.doubleValue
    }
    
    override func decodeFloatForKey(key: String) -> Float {
        let result = properties[key] as! NSNumber
        return result.floatValue
    }
    
    override func decodeBytesForKey(key: String, returnedLength lengthp: UnsafeMutablePointer<Int>) -> UnsafePointer<UInt8> {
        
        assertionFailure("Not supported")
        return nil
    }

}