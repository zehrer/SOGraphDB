//
//  ValueCoder.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 26.06.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation
import Cocoa

public protocol Coding {
    
    //Only within the Initialization of an object it is possible
    // to set the value of a stored property if it is not optional
    init(coder decoder: Decode)
    
    func encodeWithCoder(encode : Encode)
}

public protocol Encode {
    
    // --- encode ---
    
    func encode(intv : Bool)
    //func encode(intv : Bool?)
    
    func encode(intv : Int)
    func encode(intv : Int8)
    func encode(intv : Int16)
    func encode(intv : Int32)
    func encode(intv : Int64)
    
    //func encode(intv : Int?)
    //func encode(intv : Int8?)
    //func encode(intv : Int16?)
    //func encode(intv : Int32?)
    //func encode(intv : Int64?)
    
    func encode(intv : UInt)
    func encode(intv : UInt8)
    func encode(intv : UInt16)
    func encode(intv : UInt32)
    func encode(intv : UInt64)
    
    //func encode(intv : UInt?)
    //func encode(intv : UInt8?)
    //func encode(intv : UInt16?)
    //func encode(intv : UInt32?)
    //func encode(intv : UInt64?)
    
    func encode(realv: Float)
    func encode(realv: Double)
    
    //func encode(realv: Float?)
    //func encode(realv: Double?)
    
    func encode(strv: String)
    //func encode(strv: String?)
    
    //func encode(value : Coding?)
}

public protocol Decode {
    
    // --- decode ---
    
    func decode<T: Coding>() -> T?
    //func decode<T: Coding>() -> T
    
    func decode() -> UInt8
    
    func decode() -> Int?
    func decode() -> Int
    
    //func decode() -> Bool?
    func decode() -> Bool
    
    func decode() -> String?
    
}

public enum CoderType : UInt8 {
    case Nil = 0

    case String
    //case Dictionary
    //case Array
    //case Set
    case True
    case False
    case Int
    case Int8
    case Int16
    case Int32
    case Int64
    case Float32
    case Float64
    case UInt
    case UInt8
    case UInt16
    case UInt32
    case UInt64
    case Coding
    //case Data
    //case Date
    //case MutableData
    //case DecimalNumber
    case One
    case Zero
    case MinusOne
    case End
    
    case Unknown
}

public class SOEncoder : Encode {
    
    public var output = NSMutableData()
    
    var keeptIntType = false
    
    let UInt32max = UInt(UInt32.max)
    let UInt16max = UInt(UInt16.max)
    let UInt8max = UInt(UInt8.max)
    
    let Int32min = Int(Int32.min)
    let Int16min = Int(Int16.min)
    let Int8min = Int(Int8.min)
    
    // Key is a string, value is the related index
    //var stringCache = Dictionary<String,Index>()
    
    public init() {}
    
    public func reset() {
        self.output = NSMutableData()
        keeptIntType = false
    }
    
    var length : Int {
        get {
            return output.length
        }
    }
    
    
    // MARK: encode methodes
    
    public func encode(boolv : Bool) {
        if boolv {
            writeType(.True)
        } else {
            writeType(.False)
        }
    }
    
    public func encode(intv : UInt8) {
        //direct encodeing -> no cache
        writeType(.UInt8)
        writeValue(intv)
    }
    
    public func encode(intv: UInt16) {
        //direct encodeing -> no cache
        writeType(.UInt16)
        writeValue(intv)
    }
    
    public func encode(intv: UInt32) {
        //direct encodeing -> no cache
        writeType(.UInt32)
        writeValue(intv)
    }
    
    public func encode(intv : UInt64) {
        //direct encodeing -> no cache
        writeType(.UInt64)
        writeValue(intv)
    }
    
    public func encode(intv : Int8) {
        //direct encodeing -> no cache
        writeType(.Int8)
        writeValue(intv)
    }
    
    public func encode(intv: Int16) {
        //direct encodeing -> no cache
        writeType(.Int16)
        writeValue(intv)
    }
    
    public func encode(intv: Int32) {
        //direct encodeing -> no cache
        writeType(.Int32)
        writeValue(intv)
    }
    
    public func encode(intv : Int64) {
        //direct encodeing -> no cache
        writeType(.Int64)
        writeValue(intv)
    }
    
    public func encode(realv : Float) {
        //direct encodeing -> no cache
        writeType(.Float32)
        writeValue(realv)
    }
    
    public func encode(realv : Double) {
        //direct encodeing -> no cache
        writeType(.Float32)
        writeValue(realv)
    }
    
    public func encode(intv : UInt) {
        //direct encodeing -> no cache
        if keeptIntType {
            writeType(.UInt)
            writeValue(intv)
        } else {
            switch intv {
            case UInt16max...UInt32max:
                encode(UInt32(intv))
            case UInt8max...UInt16max:
                encode(UInt16(intv))
            case 0:
                writeType(.Zero)
            case 1:
                writeType(.One)
            case 1...UInt8max:
                encode(UInt8(intv))
            default:
                encode(UInt64(intv))
            }
        }
    }
    
    public func encode(intv : Int) {
        //direct encodeing -> no cache
        if keeptIntType {
            writeType(.Int)
            writeValue(intv)
        } else {
            if intv < 0 {
                switch intv {
                case -1:
                    writeType(.MinusOne)
                case Int8min...0:
                    encode(Int8(intv))
                case Int16min...Int8min:
                    encode(Int16(intv))
                case Int32min...Int16min:
                    encode(Int32(intv))
                default:
                    encode(Int64(intv))
                }
            } else {
                // possitive numbers are more efficient encoded in UInt
                encode(UInt(intv))
            }
        }
    }
    
    public func encode(element : Coding) {
        writeType(.Coding)
        element.encodeWithCoder(self)
    }
    
    
    public func encode(text: String) {
        writeType(.String)
        output.appendEncodedString(text)
    }
    
    public func encode(element : Any) {
        assertionFailure("Unsupported Root Element")
    }
    
    // MARK: WriteMethodes
    
    func writeValue<T>(value : T) {
        
        var data = value
        output.appendBytes(&data, length:sizeof(T))
    }
    
    func writeType(type : CoderType) {
        writeValue(type.rawValue)
    }
    
    /**
    // see related encode methode
    func writeString(string : String) {
        //if FastCoder.FCWriteStringAlias(self, coder: aCoder) { return }
        //aCoder.FCCacheWrittenString(self)
        writeType(.String)
        encodeOutput.appendEncodedString(string)
    }
    */

}

public class SODecoder : Decode {
    
    // data for NSRange
    
    var data : NSData
    var location = 0
    
    public init() {
        data = NSMutableData()  // add fake data ... seems user like to use resetData
    }
    
    public init(_ data: NSData) {
        self.data = data
    }
    
    public func resetData(data: NSData) {
        self.data = data
        self.location = 0
    }
    
    // MARK: protocol
    
    //public func decode<T>(data: NSData) -> T?
    
    public func decode<T : Coding>() -> T? {
        
        let type = readType()
        
        if type == .Coding {
            return T.init(coder:self)
        }
        
        return nil
    }
    
    public func decode() -> Bool {
        
        let type = readType()
        if type == .True {
            return true
        }
        
        return false
    }
    
    public func decode() -> UInt8 {
        
        let type = readType()
        
        if type == .UInt8 {
           return readUInt8()
        } else {
            assertionFailure("Wrong type")
        }
        
        return 0
    }
    
    public func decode() -> Int? {
        
        let type = readType()
        
        var result = 0
        
        switch type {
        case .Nil:
            return nil
        case .Int:
            result = readInt()
        case .Int8:
            result = Int(readInt8())
        case .Int16:
            result = Int(readInt16())
        case .Int32:
            result = Int(readInt32())
        case .Int64:
            result = Int(readInt64())
        case .Float32:
            result = Int(readFloat32())
        case .Float64:
            result = Int(readFloat64())
        case .UInt8:
            result = Int(readUInt8())
        case .UInt16:
            result = Int(readUInt16())
        case .UInt32:
            result = Int(readUInt32())
        case .UInt64:
            result = Int(readUInt64())
        case .One:
            return 1
        case .Zero:
            return 0
        case .MinusOne:
            return -1
        default:
            assertionFailure("Not supported type")
            
        }
        
        return result
    }
    
    public func decode() -> Int {
        let value : Int? = decode()
        
        if value != nil {
            return value!
        }
        
        assertionFailure("read optional value")
        
        return 0
    }
    
    public func decode() -> String? {
        
        let type = readType()
        
        switch type {
        case .Nil:
            return nil
        case .String:
            return readString()
        default:
            assertionFailure("Wrong type")
        }
        
        return nil
    }
    
    // MARK: READ
    
    func getDataSection(length : Int) -> NSData {
        let range =  NSRange(location: location, length: length)
        
        location += length
        
        return data.subdataWithRange(range)
    }
    
    func readValue<T>(inout value:T) {
        let size = sizeof(T)
        let data = getDataSection(size)
        data.getBytes(&value, length:size)
    }
    
    func readType() -> CoderType {
        
        var value : UInt8 = 0
        readValue(&value)
        
        let type = CoderType(rawValue: value)
        
        if type != nil  {
            return type!
        }
        
        return .Unknown
    }
    
    func readUInt() -> UInt {
        var value : UInt = 0
        readValue(&value)
        
        return value
    }
    
    func readUInt8() -> UInt8 {
        var value : UInt8 = 0
        readValue(&value)
        
        return value
    }
    
    func readUInt16() -> UInt16 {
        
        var value : UInt16 = 0
        readValue(&value)
        
        return value
    }
    
    func readUInt32() -> UInt32 {
        
        var value : UInt32 = 0
        readValue(&value)
        
        return value
    }
    
    func readUInt64() -> UInt64 {
        
        var value : UInt64 = 0
        readValue(&value)
        
        return value
    }
    
    func readInt() -> Int {
        var value : Int = 0
        readValue(&value)
        
        return value
    }
    
    func readInt8() -> Int8 {
        var value : Int8 = 0
        readValue(&value)
        
        return value
        
    }
    
    func readInt16() -> Int16 {
        var value : Int16 = 0
        readValue(&value)
        
        return value
    }
    
    func readInt32() -> Int32 {
        var value : Int32 = 0
        readValue(&value)
        
        return value
    }
    
    func readInt64() -> Int64 {
        var value : Int64 = 0
        readValue(&value)
        
        return value
    }
    
    func readFloat32() -> Float32 {
        var value : Float32 = 0
        readValue(&value)
        
        return value
    }
    
    func readFloat64() -> Double {
        var value : Double = 0
        readValue(&value)
        
        return value
    }
    
    // return string lengh at current location (incl. zero termination)
    func stringDataLength() -> UInt {
        let utf8 = UnsafePointer<Int8>(data.bytes + location)
        return strlen(utf8) + 1 // +1 for zero termination
    }
    
    func readString() -> String? {
        
        // get the data size of the string
        let stringLength = stringDataLength() // data.stringDataLength(offset: decoder.location)
        let stringData = getDataSection(Int(stringLength))
        
        if stringLength > 1 {
            
            return stringData.decodeStringData()
        }
        
        return ""
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