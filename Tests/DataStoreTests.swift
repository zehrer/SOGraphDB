//
//  DataStoreTests.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 08.07.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import XCTest
import SOGraphDB

class DataStoreTests: XCTestCase {

    /**
    - (NSURL *)testFile;
    {
    return
    }
*/
    class Test : Init {
        
        let a : Int
        
        init() {
            a = 0
        }
    }
    
    
    func testFile() -> NSURL {
        let url = SOTools.tempDirectory()
        return url.URLByAppendingPathComponent("data.db")
    }
    
    func test0Delete() {
        var url = testFile()
        
        url.deleteFile()
        
        XCTAssertFalse(url.isFileExisting(), "File not deleted?");
    }
    
    func test1StoreFile() {
        var url = testFile()
        
        NSLog("URL: %@", url.path)
        
        var dataStore = DataStore<ObjectStoreHeader,Test>(url: url)
        
        XCTAssertNotNil(dataStore.fileHandle,"file is not created")
        XCTAssertNil(dataStore.error, "error happend?");
        
        url.deleteFile()
        
        XCTAssertFalse(url.isFileExisting(),"File not deleted?");
    }

    func test3WriteData1() {
        
        var url = testFile()
        url.deleteFile()
        
        var dataStore = DataStore<ObjectStoreHeader,Test>(url: url)
        
        XCTAssertNotNil(dataStore.fileHandle,"file is not created");
        XCTAssertNil(dataStore.error, "error happend?");
        
        var dataValue = Test()
        
        var uid = dataStore.createBlock(dataValue)
        
        XCTAssertEqual(uid, 1, "")
    }
    
    
}



/**
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
*/