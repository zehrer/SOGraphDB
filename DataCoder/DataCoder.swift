//
//  DataCoder.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation


public class DataCoder {
    
    
    public static func  dataWithRootObject(object : NSObject) -> NSData? {
        
        var output : NSMutableData! = NSMutableData(length: 0) // TODO: define default size
        
        
        //object count placeholders
        DCWriteUInt32(0, output: output)
        DCWriteUInt32(0, output: output)
        DCWriteUInt32(0, output: output)
        
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
    
}