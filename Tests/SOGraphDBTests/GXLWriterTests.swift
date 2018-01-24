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
    var writer : GXLWriter!
    
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        xmlFileStore = XMLFileStore()
        reader = GXLReader(store: xmlFileStore)
        writer = GXLWriter(store: xmlFileStore)
    }
    
    
    func readXML(_ url: URL) {
        do {
            try reader.read(url: url)
        } catch {
            //print(error)
            XCTFail("reader throws exception")
        }
    }
    
    func writeXML(_ url: URL) {
        do {
            try writer.write(file: url)
            NSLog(url.absoluteString)
        } catch {
            //print(error)
            XCTFail("reader throws exception")
        }
    }
    
    func testBasicData1() {
        
        let url = self.testDataURL(forResource:"BasicData1")
        readXML(url!)  // read demo data
        
        let fileURL1 = testFileURL("test.txt")
        writeXML(fileURL1)
        readXML(fileURL1)
        
        let fileURL2 = testFileURL("test2.txt")
        writeXML(fileURL2)

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

