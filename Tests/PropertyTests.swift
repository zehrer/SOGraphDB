//
//  PropertyTests.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 19.05.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Cocoa
import XCTest
import SOGraphDB

class PropertyTests: XCTestCase {


    func testDefaultValue() {
        
        var property = Property()
        
        XCTAssertTrue(property.isNil, "")
        
        var boolValue = property.boolValue
        XCTAssertNil(boolValue, "not default value");
        
        var intValue = property.intValue
        XCTAssertNil(intValue, "not default value");
        
        var doubleValue = property.doubleValue
        XCTAssertNil(doubleValue, "not default value");
        
        var stringValue = property.stringValue
        XCTAssertNil(stringValue, "not default value");
        
        var dateValue = property.dateValue
        XCTAssertNil(dateValue, "not default value");
    }
    
    func testBool() {
        
        var property = Property()
        
        property.boolValue = true
        var test = property.boolValue
        XCTAssertTrue(test! == true, "")
        
        XCTAssertFalse(property.isNil, "")
        
        //var intValue = property.intValue
        //XCTAssertNil(intValue, "not default value");
        
        //var doubleValue = property.doubleValue
        //XCTAssertNil(doubleValue, "not default value");
        
        var stringValue = property.stringValue
        XCTAssertNil(stringValue, "not default value");
        
        var dateValue = property.dateValue
        XCTAssertNil(dateValue, "not default value");
    }
    
    func testInt() {
        
        var property = Property()
        
        property.intValue = Int.max
        var test = property.intValue
        XCTAssertTrue(test! == Int.max, "")
        
        XCTAssertFalse(property.isNil, "")
        
        var stringValue = property.stringValue
        XCTAssertNil(stringValue, "not default value");
        
        var dateValue = property.dateValue
        XCTAssertNil(dateValue, "not default value");
    }
    
    func testString() {
        
        var property = Property()
        
        property.stringValue = testStringUTF8U1
        var test = property.stringValue
        XCTAssertTrue(test == testStringUTF8U1, "")
        
        XCTAssertFalse(property.isNil, "")
        
        var boolValue = property.boolValue
        XCTAssertNil(boolValue, "not default value");
        
        var intValue = property.intValue
        XCTAssertNil(intValue, "not default value");
        
        var doubleValue = property.doubleValue
        XCTAssertNil(doubleValue, "not default value");
        
        var dateValue = property.dateValue
        XCTAssertNil(dateValue, "not default value");
    }
    
    
    func testDate() {
        
        var property = Property()
        
        let date = NSDate(timeIntervalSinceReferenceDate: 118800)
    
        property.dateValue = date
        var test = property.dateValue
        XCTAssertTrue(test == date, "")
        
        XCTAssertFalse(property.isNil, "")
        
        var boolValue = property.boolValue
        XCTAssertNil(boolValue, "not default value");
        
        var intValue = property.intValue
        XCTAssertNil(intValue, "not default value");
        
        var doubleValue = property.doubleValue
        XCTAssertNil(doubleValue, "not default value");
        
        var stringValue = property.stringValue
        XCTAssertNil(stringValue, "not default value");
    }
    
    


}
