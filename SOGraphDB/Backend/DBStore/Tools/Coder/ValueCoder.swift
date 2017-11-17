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
    
    func encodeWithCoder(_ encode : Encode)
}

public protocol Encode {
    
    // --- encode ---
    
    func encode(_ intv : Bool)
    //func encode(intv : Bool?)
    
    func encode(_ intv : Int)
    func encode(_ intv : Int8)
    func encode(_ intv : Int16)
    func encode(_ intv : Int32)
    func encode(_ intv : Int64)
    
    //func encode(intv : Int?)
    //func encode(intv : Int8?)
    //func encode(intv : Int16?)
    //func encode(intv : Int32?)
    //func encode(intv : Int64?)
    
    func encode(_ intv : UInt)
    func encode(_ intv : UInt8)
    func encode(_ intv : UInt16)
    func encode(_ intv : UInt32)
    func encode(_ intv : UInt64)
    
    //func encode(intv : UInt?)
    //func encode(intv : UInt8?)
    //func encode(intv : UInt16?)
    //func encode(intv : UInt32?)
    //func encode(intv : UInt64?)
    
    func encode(_ realv: Float)
    func encode(_ realv: Double)
    
    //func encode(realv: Float?)
    //func encode(realv: Double?)
    
    func encode(_ strv: String)
    
    func encode(_ date: Date)
    
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
    
    func decode() -> Date?
    func decode() -> Date
    
}

public enum CoderType : UInt8 {
    case `nil` = 0

    case string
    //case Dictionary
    //case Array
    //case Set
    case `true`
    case `false`
    case int
    case int8
    case int16
    case int32
    case int64
    case float32
    case float64
    case uInt
    case uInt8
    case uInt16
    case uInt32
    case uInt64
    case coding
    //case Data
    case date
    //case MutableData
    //case DecimalNumber
    case one
    case zero
    case minusOne
    case end
    
    case unknown
}

open class SOEncoder : Encode {
    
    open var output = NSMutableData()
    
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
    
    open func reset() {
        self.output = NSMutableData()
        keeptIntType = false
    }
    
    var length : Int {
        get {
            return output.length
        }
    }
    
    
    // MARK: encode methodes
    
    open func encode(_ boolv : Bool) {
        if boolv {
            writeType(.true)
        } else {
            writeType(.false)
        }
    }
    
    open func encode(_ intv : UInt8) {
        //direct encodeing -> no cache
        writeType(.uInt8)
        writeValue(intv)
    }
    
    open func encode(_ intv: UInt16) {
        //direct encodeing -> no cache
        writeType(.uInt16)
        writeValue(intv)
    }
    
    open func encode(_ intv: UInt32) {
        //direct encodeing -> no cache
        writeType(.uInt32)
        writeValue(intv)
    }
    
    open func encode(_ intv : UInt64) {
        //direct encodeing -> no cache
        writeType(.uInt64)
        writeValue(intv)
    }
    
    open func encode(_ intv : Int8) {
        //direct encodeing -> no cache
        writeType(.int8)
        writeValue(intv)
    }
    
    open func encode(_ intv: Int16) {
        //direct encodeing -> no cache
        writeType(.int16)
        writeValue(intv)
    }
    
    open func encode(_ intv: Int32) {
        //direct encodeing -> no cache
        writeType(.int32)
        writeValue(intv)
    }
    
    open func encode(_ intv : Int64) {
        //direct encodeing -> no cache
        writeType(.int64)
        writeValue(intv)
    }
    
    open func encode(_ realv : Float) {
        //direct encodeing -> no cache
        writeType(.float32)
        writeValue(realv)
    }
    
    open func encode(_ realv : Double) {
        //direct encodeing -> no cache
        writeType(.float32)
        writeValue(realv)
    }
    
    open func encode(_ intv : UInt) {
        //direct encodeing -> no cache
        if keeptIntType {
            writeType(.uInt)
            writeValue(intv)
        } else {
            switch intv {
            case UInt16max...UInt32max:
                encode(UInt32(intv))
            case UInt8max...UInt16max:
                encode(UInt16(intv))
            case 0:
                writeType(.zero)
            case 1:
                writeType(.one)
            case 1...UInt8max:
                encode(UInt8(intv))
            default:
                encode(UInt64(intv))
            }
        }
    }
    
    open func encode(_ intv : Int) {
        //direct encodeing -> no cache
        if keeptIntType {
            writeType(.int)
            writeValue(intv)
        } else {
            if intv < 0 {
                switch intv {
                case -1:
                    writeType(.minusOne)
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
    
    open func encode(_ element : Coding) {
        writeType(.coding)
        element.encodeWithCoder(self)
    }
    
    
    open func encode(_ text: String) {
        writeType(.string)
        output.appendEncodedString(text as NSString)
    }
    
    open func encode(_ date: Date) {
        writeType(.date)
        
        let value = date.timeIntervalSince1970
        writeValue(value)
    }
    
    open func encode(_ element : Any) {
        assertionFailure("Unsupported Root Element")
    }
    
    // MARK: WriteMethodes
    
    func writeValue<T>(_ value : T) {
        
        var data = value
        output.append(&data, length:MemoryLayout<T>.size)
    }
    
    func writeType(_ type : CoderType) {
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

open class SODecoder : Decode {
    
    // data for NSRange
    
    var data : Data
    var location = 0
    
    public init() {
        data = NSMutableData() as Data  // add fake data ... seems user like to use resetData
    }
    
    public init(_ data: Data) {
        self.data = data
    }
    
    open func resetData(_ data: Data) {
        self.data = data
        self.location = 0
    }
    
    // MARK: protocol
    
    //public func decode<T>(data: NSData) -> T?
    
    open func decode<T : Coding>() -> T? {
        
        let type = readType()
        
        if type == .coding {
            return T.init(coder:self)
        }
        
        return nil
    }
    
    open func decode() -> Bool {
        
        let type = readType()
        if type == .true {
            return true
        }
        
        return false
    }
    
    open func decode() -> UInt8 {
        
        let type = readType()
        
        if type == .uInt8 {
           return readUInt8()
        } else {
            assertionFailure("Wrong type")
        }
        
        return 0
    }
    
    open func decode() -> Int? {
        
        let type = readType()
        
        var result = 0
        
        switch type {
        case .nil:
            return nil
        case .int:
            result = readInt()
        case .int8:
            result = Int(readInt8())
        case .int16:
            result = Int(readInt16())
        case .int32:
            result = Int(readInt32())
        case .int64:
            result = Int(readInt64())
        case .float32:
            result = Int(readFloat32())
        case .float64:
            result = Int(readFloat64())
        case .uInt8:
            result = Int(readUInt8())
        case .uInt16:
            result = Int(readUInt16())
        case .uInt32:
            result = Int(readUInt32())
        case .uInt64:
            result = Int(readUInt64())
        case .one:
            return 1
        case .zero:
            return 0
        case .minusOne:
            return -1
        default:
            assertionFailure("Not supported type")
            
        }
        
        return result
    }
    
    open func decode() -> Int {
        let value : Int? = decode()
        
        if value != nil {
            return value!
        }
        
        assertionFailure("read optional value")
        
        return 0
    }
    
    open func decode() -> String? {
        
        let type = readType()
        
        switch type {
        case .nil:
            return nil
        case .string:
            return readString()
        default:
            assertionFailure("Wrong type")
        }
        
        return nil
    }
    
    open func decode() -> Date {
        
        let type = readType()
        
        if type != .date {
            assertionFailure("Wrong type")
        }
        
        return readDate()
    }
    
    open func decode() -> Date? {
        
        let type = readType()
        
        switch type {
        case .nil:
            return nil
        case .date:
            return readDate()
        default:
            assertionFailure("Wrong type")
        }
        
        return nil
    }
    
    // MARK: READ
    
    func getDataSection(_ length : Int) -> Data {
        
        let range = Range(NSRange(location: location, length: length))
    
        location += length
        
        return data.subdata(in: range!)
    }
    
    func readValue<T>(_ value:inout T) {
        let size = MemoryLayout<T>.size
        let data = getDataSection(size)
        (data as NSData).getBytes(&value, length:size)
    }
    
    func readType() -> CoderType {
        
        var value : UInt8 = 0
        readValue(&value)
        
        let type = CoderType(rawValue: value)
        
        if type != nil  {
            return type!
        }
        
        return .unknown
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
        
        // TODO: ERROR
        
        /**
        let size = data.bytes + location
        
        let utf8 = UnsafePointer<Int8>((data as NSData).bytes + location)
        
        **/
        return 0 //strlen(utf8) + 1 // +1 for zero termination
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
    
    func readDate() -> Date {
        var value : TimeInterval = 0
        readValue(&value)
        
        return Date(timeIntervalSince1970: value)
    }
}


extension NSMutableData {
    
    func appendEncodedString(_ string: NSString) {
        // encode with "dataUsingEncoding"
        var zero : UInt8 = 0
        
        //var mutableData = NSMutableData()
        
        let data = string.data(using: String.Encoding.utf8.rawValue)
        
        if data != nil {
            self.append(data!)
        }
        
        // write zero termination
        self.append(&zero, length: MemoryLayout<UInt8>.size)
        
    }
}
