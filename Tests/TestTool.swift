//
//  TestTool.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 13.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import XCTest

class TestTool {
    
    class func tempDirectory() -> NSURL {
        return NSURL(fileURLWithPath: NSTemporaryDirectory())!
    }
    
    /**
     * This method add ".wrapper" at the end
     */
    class func testWrapper(fileName: String) -> NSURL {
    
        var tempURL = TestTool.tempDirectory()
    
        return tempURL.URLByAppendingPathComponent("\(fileName).wrapper")
    
    }
    
    class func createNewTestWrapperURL(fileName: String) -> NSURL {
        
        var url = TestTool.testWrapper(fileName)
        
        println("URL: \(url.path!)")
        
        url.deleteFile();
        
        return url;
        
    }
    
    class func deleteFile(url: NSURL) {
        
        url.deleteFile();
        
        XCTAssertFalse(url.isFileExisting(), "File not deleted?");
        
    }
}
