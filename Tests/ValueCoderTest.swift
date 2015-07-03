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
    
    init(coder decoder: Coder) {
        value = decoder.decodeElementForKey("1")!
    }
    
    func encodeWithCoder(coder : Coder) {
        coder.encodeValue(value, forKey: "1")
    }
}

class ValueCoderTest: XCTestCase {
    
    func runFastCoder2<T: Encode>(element: T) -> T? {
        let data = FastCoder2.encodeRootElement(element)
        
        if data != nil {
            print("Data size . \(data!.length)")
            
            let obj : T? = FastCoder2.decodeRootElement(data!)
            
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
    
    func testBasicValueBool() {
        let input = true
        
        let output = runFastCoder2(input)
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    // encode 64 bit
    func testBasicValueInt() {
        let input = 42
        
        let output = runFastCoder2(input)
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    func testBasicValueUInt8() {
        let input : UInt8 = 42
        
        let output = runFastCoder2(input)
        
        XCTAssertTrue(input == output , "value not equal")
        XCTAssertTrue(input.self == output.self, "Type not similar")
        
        // But in reality this return a NSNumber of "type" bool and not of type Integer as created
    }
    
    func testBasicValueUInt8_short() {
        let input = 42
        
        let data = FastCoder2.encodeRootElement(input, keepIntType : false)
        
        if data != nil {
            print("Data size . \(data!.length)")
            
            let output : Int? = FastCoder2.decodeInt(data!)
            
            XCTAssertTrue(input == Int(output!) , "value not equal")
            
        }
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
