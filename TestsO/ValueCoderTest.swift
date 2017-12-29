//
//  ValueCoderTest.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 26.06.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import SOGraphDB
import XCTest

struct TestStruct : Coding {
    
    var value = 42
    
    init() {
        
    }
    
    init(coder decoder: Decode) {
        value = decoder.decode()
    }
    
    func encodeWithCoder(_ encoder : Encode) {
        encoder.encode(value)
    }
}

class ValueCoderTest: XCTestCase {
    
    var encoder = SOEncoder()
    var decoder = SODecoder()
    
   
    override func setUp() {
        super.setUp()
        
        encoder.reset()
    }
    
    /**
    func runValueCoder<T>(element: T) -> T? {
        let data = SOEncoder.encode(element)
        
        if data != nil {
            print("Data size . \(data!.length)")
            
            let obj : T? = SODecoder.decodeRootElement(data!)
            
            if obj != nil {
                return obj!
            } else {
                XCTFail("Result is nil")
            }
        }
        
        XCTFail("Data is nil")
        //assertionFailure("Data is nil")
        return nil
    }
    */
    
    func testBasicValueBool() {
        let input = true
        
        encoder.encode(input)
        decoder.resetData(encoder.output)
        
        let output : Bool = decoder.decode()
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    // encode 64 bit
    func testBasicValueInt() {
        let input = 42
        
        encoder.encode(input)
        decoder.resetData(encoder.output)
        
        let output : Int = decoder.decode()
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    func testBasicValueUInt8() {
        let input : UInt8 = 42
        
        encoder.encode(input)
        decoder.resetData(encoder.output)
        
        let output : UInt8 = decoder.decode()
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    func testBasicValueUInt8_short() {
        let input = 42
        
        encoder.encode(input)

        print("Data size . \(encoder.output.length)")
  
        decoder.resetData(encoder.output)
        let output : Int? = decoder.decode()
            
        XCTAssertTrue(input == Int(output!) , "value not equal")
    }
    
    func testDate() {
        let input = Date()
        
        encoder.encode(input)
        decoder.resetData(encoder.output)

        let output : Date = decoder.decode()
        
        if input == output { // input == output
            print("Equal")
        }
        
        let dateDiff = input.timeIntervalSince(output)
        XCTAssertTrue(dateDiff < 0.1, "value not equal")
        
        //XCTAssertTrue(input.isEqualToDate(output), "value not equal")
    }
    
    /**
    
    func testValue() {
    let input = TestStruct()
    input.value = 100
    
    let data = FastCoder2.encodeRootElement(input)
    
    if data != nil {
    print("Data size . \(data!.length)")
    
    let output : Int? = FastCoder2.decodeInt(data!)
    
    XCTAssertTrue(input == Int(output!) , "value not equal")
    
    }
    
    }
    */
    
}
