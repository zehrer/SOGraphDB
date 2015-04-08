//
//  LocalTest.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 31.08.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Cocoa
import XCTest
import SOGraphDB

public class TestClass : Coding {
    
    public struct TestData : Init {
        
        var a : Int  // 8 bytes
        
        public init() {
            a = 0;
        }
        
        init(num: Int) {
            a = num
        }
    }
    
    public var data: TestData = TestData()
    
    public var uid: UID?
    public var dirty: Bool = true
    
    public var num : Int {
        get {
            return self.data.a;
        }
    }
    
    public required init() {
        // data = TestData()
    }
    
    init (num : Int) {
        // data = TestData()
        self.data.a = num
    }
    
    //decoding NSData
    public required init(data: TestData) {
        self.data = data
    }
}

class ObjectStoreTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testFile() -> NSURL {
        //let url = SOTools.tempDirectory()
        
        let url = NSURL(fileURLWithPath : "/Users/steve/Test", isDirectory: true)
        return url.URLByAppendingPathComponent("object.db")
    }
    
    func test1StoreFile() {
        var url = testFile()
        
        NSLog("URL: %@", url.path!)
        url.deleteFile()
        
        var objectStore = ObjectDataStore<TestClass>(url: url)
        
        XCTAssertTrue(url.isFileExisting(),"A file exist?");
        
        //XCTAssertNotNil(dataStore.fileHandle,"file is not created")
        XCTAssertNil(objectStore.error, "error happend?");
        
        url.deleteFile()
        
        XCTAssertFalse(url.isFileExisting(),"File not deleted?");
    }
    
    //
    //  Create new DataStore
    //  write a block
    //  reopen this DataStore
    //  read the block
    func test2WriteData() {
        
        var url = testFile()
        url.deleteFile()
        
        var objectStore = ObjectDataStore<TestClass>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,"file is not created");
        XCTAssertNil(objectStore.error, "error happend?");
        
        var dataClass = TestClass(num:42)
        
        var uid = objectStore.addObject(dataClass)
        
        XCTAssertEqual(uid, 1, "")
        
        //objectStore = nil
        //objectStore = ObjectDataStore<TestClass>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,@"file is not created");
        //XCTAssertNil(objectStore.error, "error happend?");
        
        var result = objectStore.readObject(uid);
        
        if result != nil {
            XCTAssertEqual(result.num,42,"")
            NSLog("Data read")
        } else {
            // result is nil
            XCTFail()
        }
        
    }
}
