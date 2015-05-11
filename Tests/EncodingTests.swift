//
//  EncodingTests.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 28.03.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import XCTest
import SOGraphDB

class EncodingTests: XCTestCase {
    
    /**
    func testNodeCoding() {
        var aNode = Node()
        
        //aNode.data.nextPropertyID = 42
        
        var data = NSKeyedArchiver.archivedDataWithRootObject(aNode)
        
        //NSLog ("%i","data.length),
        println("\(data.length)")
        
        var bNode = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Node
        
        
    }
    */

    internal class Block : NSObject, NSCoding {

        var used: Bool = true
        var obj: AnyObject? = nil
        
        override init() {
            super.init()
        }
        
        init(used: Bool) {
            super.init()
            self.used = used
        }
        
        init(obj:SOCoding) {
            super.init()
            self.obj = obj
        }
        
        //MARK: NSCoding
        
        @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
            super.init()
            
            used  = decoder.decodeBoolForKey("1")
            obj = decoder.decodeObjectForKey("0")
        }
        
        @objc func encodeWithCoder(encoder: NSCoder) {
            encoder.encodeBool(used, forKey:"1")
            
            if obj != nil {
                encoder.encodeObject(obj, forKey: "0")
            }
            
        }
        
    }
    
    class A : NSObject, SOCoding {
        
        //MARK: SOCoding
        
        @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
            super.init()
        }
        
        @objc func encodeWithCoder(encoder: NSCoder) {
        }
        
        static func dataSize() -> Int {
            return 0
        }
        
        override required init() {
            
        }
        
        var uid: UID!
        var dirty: Bool = true
    }
    
    internal class E : NSObject, NSCoding {
        
        //MARK: SOCoding
        
        @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
            super.init()
        }
        
        @objc func encodeWithCoder(encoder: NSCoder) {
        }
        
        override required init() {
            
        }
        
    }
    
    func testFastCoding1() {
        
        var obj = E()
        
        var data = FastCoder.dataWithRootObject(obj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        //XCTAssertTrue(data!.length == 47, "wrong size")
        println("Node encoding size is: \(data!.length)")
    }
    
    func testEmptyClassFastCoding() {
        
        var aObj = B()
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        //var bObj = FastCoder.objectWithData(data) as! A
        
        //XCTAssertTrue(data!.length == 25, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data!.length)")
    }
    
    
    //MARK: Node
    
    func testNodeFastCoding() {
        var aObj = Node()
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        XCTAssertTrue(data!.length == 42, "wrong size")  // 50 -> 42
        println("Node encoding size is: \(data!.length)")
    }
    
    //MARK: Relationship
    
    func testRelationshipFastCoding() {
        var aObj = Relationship()
        
        var data = FastCoder.dataWithRootObject(aObj)
        var bObj = FastCoder.objectWithData(data!) as! Relationship
        
        XCTAssertTrue(data!.length == 90, "wrong size")  // 78 -> 90
        println("Relationship encoding size is: \(data!.length)")
    }
    
    //MARK: Property (MAX: 96) --> 100
    
    // Property:  (Old FastCoder figures)
    // 68  Byte without data  (71)
    // 72  Byte -> Boolean (75)
    // 80  Byte -> Int
    // 80  Byte -> Double (84)
    // 80  Byte -> NSDate (84)
    // 96  Byte -> testStringUTF8U1 (100)
    
    func testPropertyFastCoding() {
        
        var aObj = Property()  // NIL undefined value
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data!) as! Property
        
        XCTAssertTrue(data!.length == 68, "wrong size")  // 71 -> 68
        println("Property encoding size is: \(data!.length)")
    }
    
    func testPropertyFastCodingBool() {
        
        var aObj = Property()
        
        aObj.boolValue = true
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data!) as! Property
        
        XCTAssertTrue(data!.length == 72, "wrong size") // 75 -> 72
        XCTAssertTrue(aObj.boolValue == bObj.boolValue, "")
        println("Property encoding size is: \(data!.length)")
    }
    
    func testPropertyFastCodingInt() {
        
        var aObj = Property()
        
        aObj.intValue = Int.max
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data!) as! Property
        
        XCTAssertTrue(data!.length == 80, "wrong size")  // test changed
        XCTAssertTrue(aObj.intValue == bObj.intValue, "")
        println("Property encoding size is: \(data!.length)")
    }
    
    func testPropertyFastCodingDouble() {
        
        var aObj = Property()
        
        aObj.doubleValue = 3.141516178192021222300000000000000000000000000001
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Property
            
            XCTAssertTrue(data!.length == 80, "wrong size")  // 84 -> 80
            XCTAssertTrue(aObj.doubleValue == bObj.doubleValue, "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    func testPropertyFastCodingString1() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF8U1
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
        
            var bObj = FastCoder.objectWithData(data!) as! Property
            
            XCTAssertTrue(data!.length == 96, "wrong size") // 100 -> 96
            XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    func testPropertyFastCodingString2() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF16
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Property
            
            XCTAssertTrue(data!.length == 88, "wrong size")  // 92 -> 88
            XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }

    }
    
    func testPropertyFastCodingString3() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF8U4 // > 20 bytes
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Property
            
            XCTAssertTrue(data!.length == 68, "wrong size") // 71 -> 68
            //XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    func testPropertyFastCodingNSDate() {
        
        var aObj = Property()
        
        aObj.dateValue = NSDate()
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Property
            
            XCTAssertTrue(data!.length == 80, "wrong size")  // 84 -> 80
            //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
            //XCTAssertTrue(aObj.dateValue == bObj.dateValue,"")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    
    
    func testFastCodingObjectBlock2() {
        
        var aObj = Block(used: true)
        var testData = TestClass(num: Int.max)
        aObj.obj = testData
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Block
            
            XCTAssertTrue(data!.length == 103, "wrong size")  // 149 -> 103
            //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    func testFastCodingTestClass() {
        
        var aObj = TestClass(num: Int.max)
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! TestClass
            
            XCTAssertTrue(data!.length == 45, "wrong size")  // 89 -> 45
            //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
    }
    
    // Test size of ObjectBlock Class
    func testFastCodingObjectBlock1() {
        
        var aObj = Block(used: true)
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        if data != nil {
            var bObj = FastCoder.objectWithData(data!) as! Block
            
            XCTAssertTrue(data!.length == 55, "wrong size")  // 81 -> 55
            //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
            println("Property encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
        
    }
/**

        if data != nil {

        } else {
            XCTFail("Data is nil")
        }
*/
    
    func testCodingNode() {
        
        var node = Node(testdata: true)
        var aObj = Block(used: true)
        aObj.obj = node
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        if data != nil {
            XCTAssertTrue(data!.length == 112, "wrong size")  // 152 -> 112
            println("Node encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }

    }
    
    func testCodingRelationship() {
        
        var obj = Relationship(testdata: true)
        var aObj = Block(used: true)
        aObj.obj = obj
        
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        if data != nil {
            XCTAssertTrue(data!.length == 180, "wrong size")  // 240 -> 180
            println("Node encoding size is: \(data!.length)")
        } else {
            XCTFail("Data is nil")
        }
        

    }
    
    func testCodingProperty1() {
        
        var obj = Property()
        obj.stringValue = testStringUTF8U1
        
        var aObj = Block(used: true)
        aObj.obj = obj
        
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        if data != nil {
            XCTAssertTrue(data!.length == 154, "wrong size")  // 163 -> 154
            println("Node encoding size is: \(data!.length)")

        } else {
            XCTFail("Data is nil")
        }
    }
    
    
    /**
    func testPropertyCoding() {
    
    XCTAssert(true, "Pass")
    }
    
    */

}
