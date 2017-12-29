//
//  FastCoding.swift
//
//  Version 0.84
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

extension Data {
    
    /**
    func stringDataLength(offset : Int = 0) -> UInt {
        var utf8 = UnsafePointer<Int8>(self.bytes + offset)
        return strlen(utf8) + 1 // +1 for zero termination
    }
    */
    
    func decodeStringData() -> String? {
        return String(cString: (self as NSData).bytes.bindMemory(to: CChar.self, capacity: self.count))
    }
}

/**
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
*/

typealias Index = Int

open class FastCoder {
    
    enum FCType : UInt8 {
        case fcTypeNil = 0
        case fcTypeNull
        case fcTypeObjectAlias8
        case fcTypeObjectAlias16
        case fcTypeObjectAlias32
        case fcTypeStringAlias8
        case fcTypeStringAlias16
        case fcTypeStringAlias32
        case fcTypeString
        case fcTypeDictionary
        case fcTypeArray
        case fcTypeSet
        case fcTypeOrderedSet
        case fcTypeTrue
        case fcTypeFalse
        case fcTypeInt8
        case fcTypeInt16
        case fcTypeInt32
        case fcTypeInt64
        case fcTypeUInt8
        case fcTypeUInt16
        case fcTypeUInt32
        case fcTypeUInt64
        case fcTypeFloat32
        case fcTypeFloat64
        case fcTypeData
        case fcTypeDate
        case fcTypeMutableString
        case fcTypeMutableDictionary
        case fcTypeMutableArray
        case fcTypeMutableSet
        case fcTypeMutableOrderedSet
        case fcTypeMutableData
        case fcTypeClassDefinition
        case fcTypeObject8
        case fcTypeObject16
        case fcTypeObject32
        case fcTypeURL
        case fcTypePoint
        case fcTypeSize
        case fcTypeRect
        case fcTypeRange
        case fcTypeVector
        case fcTypeAffineTransform
        case fcType3DTransform
        case fcTypeMutableIndexSet
        case fcTypeIndexSet
        case fcTypeNSCodedObject
        case fcTypeDecimalNumber
        case fcTypeOne
        case fcTypeZero
        case fcTypeEnd  // mark a end (e.g. end of a list)
        
        case fcTypeUnknown // renamed FCTypeCount (entinel value)
    }

    
    // write data
    open static func dataWithRootObject(_ object : NSObject) -> Data? {
        
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

        return output as Data?
        
    }
    
    // read data
    open static func objectWithData(_ data: Data) -> NSObject? {
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
    
    static func FCReadValue<T>(_ value:inout T, decoder: FCDecoder) {
        let size = MemoryLayout<T>.size
        let data = decoder.getDataSection(size)
        (data as NSData).getBytes(&value, length:size)
    }
    
    static func FCReadType(_ decoder : FCDecoder) -> FCType {
        
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        
        let type = FCType(rawValue: value)
        
        if type != nil  {
            return type!
        }
        
        return .fcTypeUnknown
    }
    
    static func FCReadRawUInt8(_ decoder : FCDecoder) -> UInt8 {
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawUInt16(_ decoder : FCDecoder) -> UInt16 {

        var value : UInt16 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawUInt32(_ decoder : FCDecoder) -> UInt32 {
        
        var value : UInt32 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawString(_ decoder : FCDecoder) -> String? {
        
        // get the data size of the string
        let stringLength = decoder.stringDataLength() // data.stringDataLength(offset: decoder.location)
        let stringData = decoder.getDataSection(Int(stringLength))
        
        if stringLength > 1 {
        
            return stringData.decodeStringData()
        }
        
        return ""
    }
    
    static func FCReadAlias8(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt8(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadAlias16(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt16(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadAlias32(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt32(decoder)
        
        return decoder.objectCache[Int(index)]
    }
    
    static func FCReadStringAlias8(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt8(decoder)
        
        return decoder.stringCache[Int(index)] as NSObject?
    }
    
    static func FCReadStringAlias16(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt16(decoder)
        
        return decoder.stringCache[Int(index)] as NSObject?
    }
    
    static func FCReadStringAlias32(_ decoder : FCDecoder) -> NSObject? {
        let index = FCReadRawUInt32(decoder)
        
        return decoder.stringCache[Int(index)] as NSObject?
    }
    
    static func FCReadString(_ decoder : FCDecoder) -> String {
        let string = FCReadRawString(decoder)

        if string != nil {
            decoder.stringCache.append(string!)
            return string!
        }
        
        assertionFailure("ReadRaw should never return a nil string")
        return ""
    }
    
    static func FCReadMutableString(_ decoder : FCDecoder) -> String {
        
        assertionFailure("No support for MutableString")
        return ""
    }
    
    static func FCReadArray(_ decoder : FCDecoder) -> NSMutableArray {
        
        let result = NSMutableArray()
        
        while (true) {
            
            let type = FCReadType(decoder)
            
            if type == .fcTypeEnd {
                break;
            }
            
            let object = FCReadObject(type, decoder: decoder)
            if object != nil {
                 result.add(object!)
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


    static func FCReadNSCodedObject(_ decoder : FCDecoder) -> NSObject? {
        
        let className = FCReadObject(decoder) as! String
        let oldProperties = decoder.properties
        
        decoder.properties = Dictionary()
        
        while (true) {
            // read all elements as input for initWithCoder:
            let type = FCReadType(decoder)
            
            if type == .fcTypeEnd {
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
        
        let object = ObjCHelper.initClass(className, with: decoder)
        
        decoder.objectCache.append(object!)
        
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
    
    static func FCReadInt8(_ decoder : FCDecoder) -> Int8 {
        var value : Int8 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt8(_ decoder : FCDecoder) -> UInt8 {
        var value : UInt8 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }

    static func FCReadInt16(_ decoder : FCDecoder) -> Int16 {
        var value : Int16 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt16(_ decoder : FCDecoder) -> UInt16 {
        var value : UInt16 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }

    static func FCReadInt32(_ decoder : FCDecoder) -> Int32 {
        var value : Int32 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt32(_ decoder : FCDecoder) -> UInt32 {
        var value : UInt32 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadInt64(_ decoder : FCDecoder) -> Int64 {
        var value : Int64 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadUInt64(_ decoder : FCDecoder) -> UInt64 {
        var value : UInt64 = 0
        FCReadValue(&value, decoder: decoder)
        return value
    }
    
    static func FCReadFloat32(_ decoder : FCDecoder) -> Float32 {
        var value : Float32 = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadFloat64(_ decoder : FCDecoder) -> Double {
        var value : Double = 0
        FCReadValue(&value, decoder: decoder)
        
        return value
    }
    
    static func FCReadRawData(_ decoder : FCDecoder) -> Data {
        
        let length = FCReadUInt32(decoder)
        return decoder.getDataSection(Int(length))
    }
    
    
    static func FCReadData(_ decoder : FCDecoder) -> Data {
        let data = FCReadRawData(decoder)
        
        decoder.objectCache.append(data as NSObject)
        
        return data
    }
    
    static func FCReadMutableData(_ decoder : FCDecoder) -> NSMutableData {
        let temp = FCReadRawData(decoder)
        
        let data = NSMutableData(data: temp) //as Data
        
        decoder.objectCache.append(data as NSObject)
        
        return data
    }
    
    static func FCReadDate(_ decoder : FCDecoder) -> Date {
        var value : TimeInterval = 0
        FCReadValue(&value, decoder: decoder)
        
        let date = Date(timeIntervalSince1970: value)
        decoder.objectCache.append(date as NSObject)
        
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
    
    static func FCReadObject(_ decoder : FCDecoder) -> NSObject? {
        let type = FCReadType(decoder)

        return FCReadObject(type, decoder: decoder)

    }
    
    static func FCReadObject(_ type: FCType, decoder : FCDecoder) -> NSObject? {
        
        switch type {
        case .fcTypeNil:
            return nil
        case .fcTypeNull:
            return NSNull()
        case .fcTypeObjectAlias8:
            return FCReadAlias8(decoder)
        case .fcTypeObjectAlias16:
            return FCReadAlias16(decoder)
        case .fcTypeObjectAlias32:
            return FCReadAlias32(decoder)
        case .fcTypeStringAlias8:
            return FCReadStringAlias8(decoder)
        case .fcTypeStringAlias16:
            return FCReadStringAlias16(decoder)
        case .fcTypeStringAlias32:
            return FCReadStringAlias32(decoder)
        case .fcTypeString:
            return FCReadString(decoder) as NSObject?
        //case .FCTypeDictionary:
        case .fcTypeArray:
            return FCReadArray(decoder)
        case .fcTypeTrue:
            return true as NSObject?
        case .fcTypeFalse:
            return false as NSObject?
        case .fcTypeInt8:
            return NSNumber(value: FCReadInt8(decoder) as Int8)
        case .fcTypeUInt8:
            return NSNumber(value: FCReadUInt8(decoder) as UInt8)
        case .fcTypeInt16:
            return NSNumber(value: FCReadInt16(decoder) as Int16)
        case .fcTypeUInt16:
            return NSNumber(value: FCReadUInt16(decoder) as UInt16)
        case .fcTypeInt32:
            return NSNumber(value: FCReadInt32(decoder) as Int32)
        case .fcTypeUInt32:
            return NSNumber(value: FCReadUInt32(decoder) as UInt32)
        case .fcTypeInt64:
            return NSNumber(value: FCReadInt64(decoder) as Int64)
        case .fcTypeUInt64:
            return NSNumber(value: FCReadUInt64(decoder) as UInt64)
        case .fcTypeFloat32:
            return FCReadFloat32(decoder) as NSObject?
        case .fcTypeFloat64:
            return FCReadFloat64(decoder) as NSObject?
        case .fcTypeData:
            return FCReadData(decoder) as NSObject?
        case .fcTypeMutableData:
            return FCReadMutableData(decoder)
        case .fcTypeDate:
            return FCReadDate(decoder) as NSObject?
        case .fcTypeNSCodedObject:
            return FCReadNSCodedObject(decoder)
        case .fcTypeOne:
            return 1 as NSObject?
        case .fcTypeZero:
            return 0 as NSObject?
        case .fcTypeUnknown:
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
    static func FCWriteInt8(_ value: Int8, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Int8>.size)
    }
    
    // Unit8
    static func FCWriteUInt8(_ value: UInt8, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<UInt8>.size)
    }
    
    // Int16
    static func FCWriteInt16(_ value: Int16, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Int16>.size)
    }
    
    // UInt16
    static func FCWriteUInt16(_ value: UInt16, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<UInt16>.size)
    }
    
    // Int32
    static func FCWriteInt32(_ value: Int32, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Int32>.size)
    }
    
    // UInt32
    static func FCWriteUInt32(_ value: UInt32, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<UInt32>.size)
    }
    
    // Int64
    static func FCWriteInt64(_ value: Int64, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Int64>.size)
    }
    
    // UInt64
    static func FCWriteUInt64(_ value: UInt64, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<UInt64>.size)
    }
    
    static func FCWriteFloat(_ value: Float, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Float>.size)
    }
    
    static func FCWriteDouble(_ value: Double, output : NSMutableData) {
        
        var data  = value
        output.append(&data, length:MemoryLayout<Double>.size)
    }
    
    static func FCWriteString(_ string : NSString, output : NSMutableData) {
        output.appendEncodedString(string)
        
        //let dataUTF8 : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        //output .appendData(dataUTF8)
    }
    
    static func FCWriteType(_ value: FCType, output : NSMutableData)
    {
      FCWriteUInt8(value.rawValue, output: output)
     //[output appendBytes:&value length:sizeof(value)];
    }
    
    static func FCWriteObject(_ object: AnyObject?, coder : FCCoder) {
        
        if object != nil {
            if object is NSObject {
                (object! as! NSObject).FC_encodeWithCoder(coder)
            } else {
                assertionFailure("Object \"\(self)\" is not a NSObject")
            }
        } else {
            FastCoder.FCWriteType(.fcTypeNil, output: coder.output)
        }
    }
    
    static func FCAlignOutput(_ size : Int, output : NSMutableData) {
        let algin = output.length % size
        if algin > 0 {
            output.increaseLength(by: size - algin)
        }
    }

    
    static func FCWriteObjectAlias(_ object : NSObject, coder : FCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        let index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                FCWriteType(.fcTypeObjectAlias8, output: coder.output)
                FCWriteUInt8(UInt8(index!), output: coder.output)
                return true
            case max8...max16:
                FCWriteType(.fcTypeObjectAlias16, output: coder.output)
                FCAlignOutput(MemoryLayout<UInt16>.size, output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                FCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                FCWriteType(.fcTypeObjectAlias32, output: coder.output)
                FCAlignOutput(MemoryLayout<UInt32>.size, output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
                FCWriteUInt32(UInt32(index!), output:coder.output)
                return true
            }
        }
        
        return false
    }
    
    static func FCWriteStringAlias(_ object : NSObject, coder : FCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        let index = coder.objectCache[object]
        
        if index != nil {
            switch index! {
            case 0...max8:
                FCWriteType(.fcTypeStringAlias8, output: coder.output)
                FCWriteUInt8(UInt8(index!), output: coder.output)
            case max8...max16:
                FCWriteType(.fcTypeStringAlias16, output: coder.output)
                FCAlignOutput(MemoryLayout<UInt16>.size, output: coder.output) // //FC_ALIGN_OUTPUT(uint16_t, coder->_output);
                FCWriteUInt16(UInt16(index!), output:coder.output)
                return true
            default:
                FCWriteType(.fcTypeStringAlias32, output: coder.output)
                FCAlignOutput(MemoryLayout<UInt32>.size, output: coder.output) // //FC_ALIGN_OUTPUT(uint32_t, coder->_output);
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
    @objc public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        // TODO
        
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        
        //handle NSCoding
        //not support for "preferFastCoding"
        
        if let object = self as? NSCoding {
            // write type and class name
            FastCoder.FCWriteType(.fcTypeNSCodedObject, output: aCoder.output)
            FastCoder.FCWriteObject(NSStringFromClass(self.classForCoder) as AnyObject?, coder: aCoder)
            
            // encode all elements of the obj
            object.encode(with: aCoder)
            
            // put it in the "after" encodeWithCoder call cache
            aCoder.FCCacheWrittenObject(self)
            
            // write end signal
            FastCoder.FCWriteType(.fcTypeEnd, output: aCoder.output)
        } else {
            //let className = toString(self).componentsSeparatedByString(".").last!
            assertionFailure("Class \"\(self)\" don't support NSCodings")
        }
    }
    
}


extension NSString {

    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        
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
            FastCoder.FCWriteType(.fcTypeString, output:aCoder.output)
//        }
        
        FastCoder.FCWriteString(self, output: aCoder.output)
    }
}

extension NSNumber {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        
        //let type = CFNumberGetType(self as CFNumberRef)
        
        let type  = String(cString: self.objCType)

        switch type {
        case "f": //.FloatType, .Float32Type:
            FastCoder.FCWriteType(.fcTypeFloat32, output:aCoder.output)
            var value = self.floatValue
            //FC_ALIGN_OUTPUT(Float32, coder->_output);
            aCoder.output.append(&value, length:MemoryLayout<Float>.size)
            
        case "d": //.DoubleType, .CGFloatType, .Float64Type:
            FastCoder.FCWriteType(.fcTypeFloat64, output:aCoder.output)
            var value = self.doubleValue
            //FC_ALIGN_OUTPUT(Float64, coder->_output);
            aCoder.output.append(&value, length:MemoryLayout<Double>.size)
            
        case "Q":
            var value = self.uint64Value
            if  value > UInt64(UInt32.max) {
                FastCoder.FCWriteType(.fcTypeUInt64, output:aCoder.output)
                aCoder.output.append(&value, length:MemoryLayout<UInt64>.size)
            } else {
                fallthrough
            }
        case "L":
            var value = self.uint32Value
            if  value > UInt32(UInt16.max) {
                FastCoder.FCWriteType(.fcTypeUInt32, output:aCoder.output)
                aCoder.output.append(&value, length:MemoryLayout<UInt32>.size)
            } else {
                fallthrough
            }
        case "S":
            var value = self.uint16Value
            if  value > UInt16(UInt8.max) {
                FastCoder.FCWriteType(.fcTypeUInt16, output:aCoder.output)
                aCoder.output.append(&value, length:MemoryLayout<UInt16>.size)
            } else {
                fallthrough
            }
        case "C":
            var value = self.uint8Value
            FastCoder.FCWriteType(.fcTypeUInt8, output:aCoder.output)
            aCoder.output.append(&value, length:MemoryLayout<UInt8>.size)
        case "q": //.SInt64Type, .LongLongType, .NSIntegerType:
            var value = self.int64Value
            if (value > Int64(Int32.max)) || (value < Int64(Int32.min)) {
                FastCoder.FCWriteType(.fcTypeInt64, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int64_t, coder->_output);
                aCoder.output.append(&value, length:MemoryLayout<Int64>.size)
            } else {
                fallthrough
            }
        case "i", "l": //.SInt32Type, .IntType, .LongType, .CFIndexType:
            var value = self.int32Value
            if (value > Int32(Int16.max)) || (value < Int32(Int16.min)) {
                FastCoder.FCWriteType(.fcTypeInt32, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int32_t, coder->_output);
                aCoder.output.append(&value, length:MemoryLayout<Int32>.size)
            } else {
                fallthrough
            }

        case "s" : //.SInt16Type, .ShortType:
            var value = self.int16Value
            if (value > Int16(Int8.max)) || (value < Int16(Int8.min)) {
                FastCoder.FCWriteType(.fcTypeInt16, output:aCoder.output)
                //FC_ALIGN_OUTPUT(int16_t, coder->_output);
                aCoder.output.append(&value, length:MemoryLayout<Int16>.size)
            } else {
                fallthrough
            }
        case "c": //.SInt8Type, .CharType:
            var value = self.int8Value
            switch value {
            case 1:
                if self == kCFBooleanTrue {
                    FastCoder.FCWriteType(.fcTypeTrue, output:aCoder.output)
                } else  {
                    FastCoder.FCWriteType(.fcTypeOne, output:aCoder.output)
                }
                    
            case 0:
                if self == kCFBooleanTrue {
                    FastCoder.FCWriteType(.fcTypeFalse, output:aCoder.output)
                } else {
                    FastCoder.FCWriteType(.fcTypeZero, output:aCoder.output)
                }
            default:
                FastCoder.FCWriteType(.fcTypeInt8, output:aCoder.output)
                aCoder.output.append(&value, length:MemoryLayout<Int8>.size)
            }
        default:
            assertionFailure("Unhandeld type")
        }

    }
}

extension NSDecimalNumber {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension Date {
    
    //override
    public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        
        if FastCoder.FCWriteObjectAlias(self as NSObject, coder: aCoder) { return }
        aCoder.FCCacheWrittenObject(self as NSObject)
        FastCoder.FCWriteType(.fcTypeDate, output:aCoder.output)
        
        var value = self.timeIntervalSince1970
        aCoder.output.append(&value, length:MemoryLayout<TimeInterval>.size)
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

extension Data {
    
    //override
    public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        
        if FastCoder.FCWriteObjectAlias(self as NSObject, coder: aCoder) { return }
        aCoder.FCCacheWrittenObject(self as NSObject)
        
        if self is NSMutableData {
            FastCoder.FCWriteType(.fcTypeMutableData, output:aCoder.output)
        } else {
            FastCoder.FCWriteType(.fcTypeData, output:aCoder.output)
        }
        
        FastCoder.FCWriteUInt32(UInt32(count), output:aCoder.output)
        aCoder.output.append(self)
    }
}

/**
    FC_ALIGN_OUTPUT(uint32_t, coder->_output);
    coder->_output.length += (4 - ((length % 4) ?: 4));
*/

extension NSNull {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
        //FastCoder.FCWriteType(.FCTypeNull, output:aCoder.output)
    }
}

extension NSDictionary {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}


extension NSArray {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        
        //var mutable = self is NSMutableArray
        
        FastCoder.FCWriteType(.fcTypeArray, output:aCoder.output)
        
        for item in self {
            FastCoder.FCWriteObject(item as AnyObject?, coder: aCoder)
        }
        
        FastCoder.FCWriteType(.fcTypeEnd, output:aCoder.output)
        
        aCoder.FCCacheWrittenObject(self)

    }

}

extension NSSet {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSOrderedSet {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension IndexSet {
    
    // override
    public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension URL {
    
    //override
    public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        if FastCoder.FCWriteStringAlias(self as NSObject, coder: aCoder) { return }
        FastCoder.FCWriteType(.fcTypeURL, output:aCoder.output);
        FastCoder.FCWriteObject(self.relativeString as AnyObject?, coder: aCoder)
        //FCWriteObject(self.relativeString, coder);
        FastCoder.FCWriteObject(self.baseURL as AnyObject?, coder: aCoder)
        //FCWriteObject(self.baseURL, coder);
        
        //aCoder.FCCacheWrittenString(self.)
        // TODO: is string cache here an bug?
        //FCCacheWrittenObject(self, coder->_stringCache);
    }
}

extension NSValue {
    
    @objc override public func FC_encodeWithCoder(_ aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

// --------------------------------------------------------------------------------

open class FCCoder : NSCoder {

    var rootObject : NSObject! = nil
    var output : NSMutableData! = nil
    var objectCache : Dictionary<NSObject,Index>! = nil
    var classCache : Dictionary<ClassDefinition, Index>! = nil
    var stringCache : Dictionary<String,Index>! = nil
    var classesByName : Dictionary<String,ClassDefinition>! = nil
    
    final func FCCacheWrittenObject(_ object : NSObject) -> Int {
        // index have to start with 0, 
        //let count = objectCache.count
        objectCache[object] = objectCache.count //+ 1
        return objectCache.count
    }
    
    final func FCCacheWrittenString(_ string : NSString) -> Int {
        
        let count = stringCache.count
        stringCache[string as String] = count + 1
        return count
    }
    
    // no impelemtation for FCIndexOfCachedObject required
    // use: var index = coder.objectCache[object]
    
    override open var allowsKeyedCoding: Bool {
        get {
            return true
        }
    }
    
    override open func encode(_ objv: Any?, forKey key: String) {
        FastCoder.FCWriteObject(objv as AnyObject?, coder: self)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
    }
    
    override open func encodeConditionalObject(_ objv: Any?, forKey key: String) {
        
        // This implementation is a more or less 1:1 port of the implementation inf
        // in the objc version of FactCoder
        // According my understanding fullfill this not the NSCoder requirements
        // this method write the reference if the object was already stored
        // But what is with the case the when the object will be stored later?
        // see original code

        if let obj = objv as? NSObject {
           let index = objectCache[obj]
            
            if index != nil {
                FastCoder.FCWriteObject(objv as AnyObject?, coder: self)
                FastCoder.FCWriteObject(key as AnyObject?, coder: self)
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
    
    override open func encode(_ boolv: Bool, forKey key: String) {
        
        if boolv {
            FastCoder.FCWriteType(.fcTypeTrue, output: output)
        } else {
            FastCoder.FCWriteType(.fcTypeFalse, output: output)
        }
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
        
        // original
        //FastCoder.FCWriteObject(NSNumber(bool: boolv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)

    }
    
    override open func encodeCInt(_ intv: Int32, forKey key: String) {
        FastCoder.FCWriteType(.fcTypeInt32, output: output)
        FastCoder.FCWriteInt32(intv, output: output)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
        
        
        // original
        //FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override open func encode(_ intv: Int32, forKey key: String) {
        FastCoder.FCWriteType(.fcTypeInt32, output: output)
        FastCoder.FCWriteInt32(intv, output: output)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
        
        // original
        //FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override open func encode(_ intv: Int64, forKey key: String) {
        
        FastCoder.FCWriteType(.fcTypeInt64, output: output)
        FastCoder.FCWriteInt64(intv, output: output)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)

        // original
        //FastCoder.FCWriteObject(NSNumber(longLong: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override open func encode(_ intv: Int, forKey key: String) {
        
        if (intv > Int(Int32.max)) || (intv < Int(Int32.min)) {
            encode(Int64(intv), forKey: key)
        } else {
            encode(Int32(intv), forKey: key)
        }
        
        //FastCoder.FCWriteObject(NSNumber(long: intv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override open func encode(_ realv: Float, forKey key: String) {
        FastCoder.FCWriteType(.fcTypeFloat32, output: output)
        FastCoder.FCWriteFloat(realv, output: output)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
        
        //FastCoder.FCWriteObject(NSNumber(float: realv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    override open func encode(_ realv: Double, forKey key: String) {
        
        FastCoder.FCWriteType(.fcTypeFloat64, output: output)
        FastCoder.FCWriteDouble(realv, output: output)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
        
        //FastCoder.FCWriteObject(NSNumber(double: realv), coder: self)
        //FastCoder.FCWriteObject(key, coder: self)
    }
    
    /**
    override open func encodeBytes(_ bytesp: UnsafePointer<UnsafePointer<UInt8>>?, length lenv: Int, forKey key: String) {
        FastCoder.FCWriteObject(Data(bytes: UnsafePointer<UInt8>(bytesp!), count: lenv) as AnyObject?, coder: self)
        FastCoder.FCWriteObject(key as AnyObject?, coder: self)
    }
    */
}

class FCDecoder : NSCoder {
    
    let data : Data
    
    init(data: Data) {
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
    

    func dataRange(_ length : Int) -> NSRange {
        let result =  NSRange(location: location, length: length)
        
        location += length
        
        return result
    }

    
    func getDataSection(_ length : Int) -> Data {
        
        let range = Range(dataRange(length))
        
        return data.subdata(in: range!)
    }
    
    // return string lengh at current location (incl. zero termination)
    func stringDataLength() -> UInt {
        
        
        /**
        let utf8 = UnsafePointer<Int8>((data as NSData).bytes + location)
        return strlen(utf8) + 1 // +1 for zero termination
        **/
        
        return 0
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
    
    override func containsValue(forKey key: String) -> Bool {
        return properties[key] != nil
    }
    
    override func decodeObject(forKey key: String) -> Any? {
        return properties[key]
    }
    
    override func decodeBool(forKey key: String) -> Bool {
        let result = properties[key] as! NSNumber
        return result.boolValue
    }
    
    override func decodeCInt(forKey key: String) -> Int32 {
        let result = properties[key] as! NSNumber
        return result.int32Value
    }
    
    override func decodeInteger(forKey key: String) -> Int {
        let result = properties[key] as! NSNumber
        return result.intValue
    }
    
    override func decodeInt64(forKey key: String) -> Int64 {
        let result = properties[key] as! NSNumber
        return result.int64Value
    }
    
    override func decodeInt32(forKey key: String) -> Int32 {
        let result = properties[key] as! NSNumber
        return result.int32Value
    }
    
    override func decodeDouble(forKey key: String) -> Double {
        let result = properties[key] as! NSNumber
        return result.doubleValue
    }
    
    override func decodeFloat(forKey key: String) -> Float {
        let result = properties[key] as! NSNumber
        return result.floatValue
    }
    
    /**
    override func decodeBytes(forKey key: String, returnedLength lengthp: UnsafeMutablePointer<UnsafeMutablePointer<Int>>?) -> UnsafePointer<UnsafePointer<UInt8>>? {
        
        assertionFailure("Not supported")
        return nil
    }
    */
}
