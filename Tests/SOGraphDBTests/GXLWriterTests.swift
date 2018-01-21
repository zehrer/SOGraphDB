//
//  GXLWriterTests.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 21.01.18.
//

import XCTest
@testable import SOGraphDB

class GXLWriterTests: SOTestCase {
    
    var xmlFileStore : XMLFileStore!
    var reader : GXLReader!
    
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        xmlFileStore = XMLFileStore()
        reader = GXLReader(store: xmlFileStore)
    }
    
    
    func testBasicData1() {
        let url = self.testDataURL(forResource:"BasicData1")
        
        do {
            try reader.read(url: url!)
        } catch {
            //print(error)
            XCTFail("reader throws exception")
        }
        
        let writer = GXLWriter(store: xmlFileStore)
        
        let file = "test.txt"
        var fileURL = FileManager.default.temporaryDirectory
        fileURL.appendPathComponent(file)
        

        do {
            let text = writer.writeXML()
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
            NSLog(fileURL.absoluteString)
        } catch {
            //print(error)
            XCTFail("reader throws exception")
        }
    }
    
    /**
     func testPerformanceExample() {
     // This is an example of a performance test case.
     self.measure {
     // Put the code you want to measure the time of here.
     }
     }
     */
    
}

