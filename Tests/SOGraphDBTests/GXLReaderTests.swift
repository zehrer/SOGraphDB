//
//  GXLParser.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 04.01.18.
//

import XCTest
@testable import SOGraphDB

class GXLReaderTests: SOTestCase {
    
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
            try reader.read(from: url!)
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
