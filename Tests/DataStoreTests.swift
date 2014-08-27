//
//  DataStoreTests.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 08.07.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import XCTest
import SOGraphDB

struct TestHeader : DataStoreHeader  {
    
    var used: Bool = true;  // 1 byte
    
}

class DataStoreTests: XCTestCase {

    /**
    - (NSURL *)testFile;
    {
    return
    }
*/
    
    struct Test : Init {
        
        var a : Int  // 8 bytes
        
        init() {
            a = 0;
        }
        
        init(num: Int) {
            a = num
        }
    }
    
    
    func testFile() -> NSURL {
        //let url = SOTools.tempDirectory()
        
        let url = NSURL(fileURLWithPath : "/Users/steve/Test", isDirectory: true)
        return url.URLByAppendingPathComponent("data.db")
    }
    
    /**
    func test0Delete() {
        var url = testFile()
        
        url.deleteFile()
        
        XCTAssertFalse(url.isFileExisting(), "File not deleted?");
    }
    */
    
    func test1StoreFile() {
        var url = testFile()
        
        NSLog("URL: %@", url.path!)
        url.deleteFile()
        
        var dataStore = DataStore<TestHeader,Test>(url: url)
        
        XCTAssertTrue(url.isFileExisting(),"A file exist?");
        
        //XCTAssertNotNil(dataStore.fileHandle,"file is not created")
        XCTAssertNil(dataStore.error, "error happend?");
        
        //var dataValue = Test(num:42)
        //var uid = dataStore.createBlock(dataValue)
        
        url.deleteFile()
        
        XCTAssertFalse(url.isFileExisting(),"File not deleted?");
    }

    //
    //  Create new DataStore
    //  write a block
    //  reopen this DataStore
    //  read the block
    func test3WriteData() {
        
        var url = testFile()
        url.deleteFile()
        
        var dataStore = DataStore<TestHeader,Test>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,"file is not created");
        XCTAssertNil(dataStore.error, "error happend?");
        
        var dataValue = Test(num:42)

        var uid = dataStore.createBlock(dataValue)
        
        XCTAssertEqual(uid, 1, "")
        
        dataStore = DataStore<TestHeader,Test>(url: url)
        
        //XCTAssertNotNil(dataStore.fileHandle,@"file is not created");
        XCTAssertNil(dataStore.error, "error happend?");
        
        var result : Test! = nil
        
        result = dataStore.readBlock(uid);
        
        if result != nil {
            XCTAssertEqual(result.a,42,"")
        } else {
            // result is nil
            XCTFail()
        }
        
    }


}

/**

- (void)test3WriteData2
{


NSUInteger dataValue = 42;
NSData *data = [[NSData alloc] initWithBytes:&dataValue length:sizeof(dataValue)];

unsigned long long pos = [fileStore endOfFile] +1;

[fileStore write:data atPos:pos];

}


*/


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