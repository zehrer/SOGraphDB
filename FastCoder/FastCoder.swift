//
//  FastCoding.swift
//
//  Version 0.1
//
//  Created by Stephan Zehrer 04/21/2015
//  Copyright (c) 2015 Stephan Zehrer
//  Obj-C Version created by Nick Lockwood on 09/12/2013.
// 
// 
// This is a port of the the Obj-C librays FastCoding to SWIFT 1.2
// https://github.com/nicklockwood/FastCoding
//  
// 
//
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

struct FCHeader {
    let identifier : UInt32 = 1178686292  // 'FAST'
    let majorVersion : UInt16 = 3
    let minorVersion : UInt16 = 2
}

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

public class FastCoder {
    
    public static func objectWithData(data: NSData) -> AnyObject? {
        return FCParseData(data)
    }

    
    public static func  dataWithRootObject(object : NSObject) -> NSData? {
        
        var output : NSMutableData! = NSMutableData(length: 0) // TODO: define default size
        
        //object count placeholders
        FCWriteUInt32(0, output: output)
        FCWriteUInt32(0, output: output)
        FCWriteUInt32(0, output: output)
        
        // Key is a object, values are the related index
        var objectCache = Dictionary<NSObject,Index>()
        
        // Key is a class, value is the related index
        var classCache = Dictionary<ClassDefinition, Index>()
        
        // Key is a string, value is the related index
        var stringCache = Dictionary<String,Index>()
        
        // Key is the class name, value is the ClassDefinition
        var classesByName = Dictionary<String,ClassDefinition>()
        
        //create coder
        
        var coder = FCCoder()
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
    
    static func FCParseData( data: NSData) -> AnyObject? {
        // TODO: FCTypeConstructor *constructors[]
        
        let length = data.length
        
        /**
        if length < sizeof(FCHeader) {
            //not a valid FastArchive
            return nil
        }
        */
    }
    
    /**
    
    //read header
    FCHeader header;
    const void *input = data.bytes;
    memcpy(&header, input, sizeof(header));
    if (header.identifier != FCIdentifier)
    {
    //not a FastArchive
    return nil;
    }
    if (header.majorVersion < 2 || header.majorVersion > FCMajorVersion)
    {
    //not compatible
    NSLog(@"This version of the FastCoding library doesn't support FastCoding version %i.%i files", header.majorVersion, header.minorVersion);
    return nil;
    }
    
    //create decoder
    NSUInteger offset = sizeof(header);
    FCNSDecoder *decoder = FC_AUTORELEASE([[FCNSDecoder alloc] init]);
    decoder->_constructors = constructors;
    decoder->_input = input;
    decoder->_offset = &offset;
    decoder->_total = length;
    
    //read data
    __autoreleasing NSMutableData *objectCache = [NSMutableData dataWithCapacity:FCReadRawUInt32(decoder) * sizeof(id)];
    decoder->_objectCache = objectCache;
    if (header.majorVersion < 3)
    {
    return FCReadObject_2_3(decoder);
    }
    else
    {
    __autoreleasing NSMutableData *classCache = [NSMutableData dataWithCapacity:FCReadRawUInt32(decoder) * sizeof(id)];
    __autoreleasing NSMutableData *stringCache = [NSMutableData dataWithCapacity:FCReadRawUInt32(decoder) * sizeof(id)];
    __autoreleasing NSMutableArray *propertyDictionaryPool = CFBridgingRelease(CFArrayCreateMutable(NULL, 0, NULL));
    
    decoder->_classCache = classCache;
    decoder->_stringCache = stringCache;
    decoder->_propertyDictionaryPool = propertyDictionaryPool;
    
    #if FC_DIAGNOSTIC_ENABLED
    
    printf("Input cache:\n");
    
    #endif
    
    @try
    {
    return FCReadObject(decoder);
    }
    @catch (NSException *exception)
    {
    NSLog(@"%@", [exception reason]);
    return nil;
    }
    }
    }
    */
    
    public static func objectWithData(data : NSData) -> NSObject? {
        var output : NSObject? = nil
    
    
        return output
    }
    
    
    // MARK: Write Methode
    
    static func FCWriteBool(value: Bool, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Bool))
    }
    
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
    
    /**
    static func FCWriteInt(inout value: Int, inout output : NSMutableData) {
        
        //var data  = value
        output.appendBytes(&value, length:sizeof(Int64))
    }
    */
    
    static func FCWriteFloat(value: Float, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Float))
    }
    
    static func FCWriteDouble(value: Double, output : NSMutableData) {
        
        var data  = value
        output.appendBytes(&data, length:sizeof(Double))
    }
    
    static func FCWriteString(string : NSString, output : NSMutableData) {
        let dataUTF8 : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        output .appendData(dataUTF8)
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
        var algin = output.length % size
        if algin > 0 {
            output.increaseLengthBy(size - algin)
        }
    }

    
    static func FCWriteObjectAlias(object : NSObject, coder : FCCoder) -> Bool {
        
        let max8 = Int(UInt8.max)
        let max16 = Int(UInt16.max)
        
        var index = coder.objectCache[object]
        
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
        
        var index = coder.objectCache[object]
        
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
    
    @objc public func FC_encodeWithCoder(aCoder: FCCoder) {
        // TODO
        
        if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
        
        //handle NSCoding
        //not support for "preferFastCoding"
        
        if self is NSCoding {
            FastCoder.FCWriteType(.FCTypeNSCodedObject, output: aCoder.output)
            FastCoder.FCWriteObject(NSStringFromClass(self.classForCoder), coder: aCoder)
            (self as! NSCoding).encodeWithCoder(aCoder)
            FastCoder.FCWriteType(.FCTypeNil, output: aCoder.output)
            aCoder.FCCacheWrittenObject(self)
            
        } else {
            //let className = toString(self).componentsSeparatedByString(".").last!
            assertionFailure("Class \"\(self)\" don't support NSCodings")
        }
    }
    
}


extension NSString {

    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        
        if self is NSMutableString   {
            if FastCoder.FCWriteObjectAlias(self, coder: aCoder) { return }
            aCoder.FCCacheWrittenObject(self)
            FastCoder.FCWriteType(.FCTypeMutableString, output:aCoder.output);
        } else {
            if FastCoder.FCWriteStringAlias(self, coder: aCoder) { return }
            //FCCacheWrittenObject(self, coder->_stringCache);
            //FCWriteType(FCTypeString, coder->_output);
        }
        
        FastCoder.FCWriteString(self, output: aCoder.output)
    }

}

extension NSNumber {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSDecimalNumber {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSDate {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSData {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSNull {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
    }
}

extension NSDictionary {
    
    @objc override public func FC_encodeWithCoder(aCoder: FCCoder) {
        assertionFailure("Not supported object type")
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
        
        let count = objectCache.count
        objectCache[object] = count + 1
        return count
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
        
        // FCWriteObject(@(boolv), self);
        FastCoder.FCWriteObject(NSNumber(bool: boolv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
        
        // TODO improve and use FCWriteBool methode
    }
    
    override public func encodeInt(intv: Int32, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInt32(intv: Int32, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(int: intv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInt64(intv: Int64, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(longLong: intv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeInteger(intv: Int, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(long: intv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeFloat(realv: Float, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(float: realv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeDouble(realv: Double, forKey key: String) {
        FastCoder.FCWriteObject(NSNumber(double: realv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }
    
    override public func encodeBytes(bytesp: UnsafePointer<UInt8>, length lenv: Int, forKey key: String) {
        FastCoder.FCWriteObject(NSData(bytes: bytesp, length: lenv), coder: self)
        FastCoder.FCWriteObject(key, coder: self)
    }

}

class FCDecoder : NSCoder {
    
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