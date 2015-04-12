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
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }


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
    
    
    //MARK: Node
    
    func testNodeFastCoding() {
        var aObj = Node()
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        XCTAssertTrue(data.length == 50, "wrong size")
        println("Node encoding size is: \(data.length)")
    }
    
    //MARK: Relationship
    
    func testRelationshipFastCoding() {
        var aObj = Relationship()
        
        var data = FastCoder.dataWithRootObject(aObj)
        var bObj = FastCoder.objectWithData(data) as! Relationship
        
        XCTAssertTrue(data.length == 78, "wrong size")
        println("Relationship encoding size is: \(data.length)")
    }
    
    //MARK: Property (MAX: 100Byte)
    
    // Property:
    // 71 Byte without data
    // 75 Byte -> Boolean
    // 76 Byte -> Int
    // 84 Byte -> Double
    // 84 Byte -> NSDate
    
    func testPropertyFastCoding() {
        
        var aObj = Property()  // NIL undefined value
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 71, "wrong size")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingBool() {
        
        var aObj = Property()
        
        aObj.boolValue = true
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 75, "wrong size")
        XCTAssertTrue(aObj.boolValue == bObj.boolValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingInt() {
        
        var aObj = Property()
        
        aObj.intValue = 42
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 76, "wrong size")
        XCTAssertTrue(aObj.intValue == bObj.intValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingDouble() {
        
        var aObj = Property()
        
        aObj.doubleValue = 3.1415
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 84, "wrong size")
        XCTAssertTrue(aObj.doubleValue == bObj.doubleValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingString1() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF8U1
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 100, "wrong size")
        XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingString2() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF16
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 92, "wrong size")
        XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingString3() {
        
        var aObj = Property()
        
        aObj.stringValue = testStringUTF8U4 // > 20 bytes
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 71, "wrong size")
        //XCTAssertTrue(aObj.stringValue == bObj.stringValue, "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testPropertyFastCodingNSDate() {
        
        var aObj = Property()
        
        aObj.dateValue = NSDate()
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Property
        
        XCTAssertTrue(data.length == 84, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data.length)")
    }
    
    
    // Test size of ObjectBlock Class
    func testFastCodingObjectBlock1() {
        
        var aObj = Block(used: true)
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Block
        
        XCTAssertTrue(data.length == 81, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testFastCodingObjectBlock2() {
        
        var aObj = Block(used: true)
        var testData = TestClass(num: Int.max)
        aObj.obj = testData
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! Block
        
        XCTAssertTrue(data.length == 149, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testFastCodingTestClass() {
        
        var aObj = TestClass(num: Int.max)
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! TestClass
        
        XCTAssertTrue(data.length == 89, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data.length)")
    }
    
    func testEmptyClassFastCoding() {
        
        var aObj = A()
        
        var data = FastCoder.dataWithRootObject(aObj)
        
        var bObj = FastCoder.objectWithData(data) as! A
        
        XCTAssertTrue(data.length == 65, "wrong size")
        //XCTAssertTrue(aObj.dateValue!.isEqual(bObj.dateValue) , "")
        println("Property encoding size is: \(data.length)")
    }
    
    /**
    func testPropertyCoding() {
     
        XCTAssert(true, "Pass")
    }
    
    */
    
    func testCodingNode() {
        
        var node = Node(testdata: true)
        var aObj = Block(used: true)
        aObj.obj = node
        
        
        var data = FastCoder.dataWithRootObject(aObj)
        //var bObj = FastCoder.objectWithData(data) as Node
        
        XCTAssertTrue(data.length == 152, "wrong size")
        println("Node encoding size is: \(data.length)")
    }

}
