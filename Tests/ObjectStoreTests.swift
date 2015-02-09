//
//  ObjectStoreTests.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 27.08.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//


import XCTest
import SOGraphDB

class TestClass : Coding {
    
    struct TestData : Init {
        
        var a : Int  // 8 bytes
        
        init() {
            a = 0;
        }
        
        init(num: Int) {
            a = num
        }
    }
    
    var data: TestData = TestData()
    
    var uid: UID?
    var dirty: Bool = true
    
    var num : Int {
        get {
            return self.data.a;
        }
    }

    required init() {
        // data = TestData()
    }
    
    init (num : Int) {
        // data = TestData()
        self.data.a = num
    }
    
    //decoding 
    required init(data: TestData) {
        self.data = data
    }
}

class ObjectStoreTests: XCTestCase {
    
    func testFile() -> NSURL {
        //let url = SOTools.tempDirectory()
        
        let url = NSURL(fileURLWithPath : "/Users/steve/Test", isDirectory: true)
        return url!.URLByAppendingPathComponent("object.db")
    }

    func test1StoreFile() {
        var url = testFile()
        
        NSLog("URL: %@", url.path!)
        url.deleteFile()
        
        var objectStore = ObjectStore<TestClass>(url: url)
        
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
        
        var objectStore = ObjectStore<TestClass>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,"file is not created");
        XCTAssertNil(objectStore.error, "error happend?");
        
        var dataClass = TestClass(num:42)
        
        var uid = objectStore.addObject(dataClass)
        
        XCTAssertEqual(uid, 1, "")
        
        //objectStore = nil
        objectStore = ObjectStore<TestClass>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,@"file is not created");
        //XCTAssertNil(objectStore.error, "error happend?");
        
        var result = objectStore.readObject(uid);
        
        if result != nil {
            XCTAssertEqual(result.num,42,"")
        } else {
            // result is nil
            XCTFail()
        }
        
    }
}
