//
//  GXLParser.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 04.01.18.
//

import XCTest
@testable import SOGraphDB

class GXLReaderTests: XCTestCase {
    
    var xmlFileStore : XMLFileStore!
    var reader : GXLReader!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        xmlFileStore = XMLFileStore()
        reader = GXLReader(store: xmlFileStore)
    }
    
    
    // Add all test data files to the bundle
    func testDataURL(forResource res: String) -> URL? {
        let testBundle = Bundle(for: type(of: self))
        guard let ressourceURL = testBundle.url(forResource: res, withExtension: "xml") else {
            XCTFail("file does not exist")
            return nil
        }
        return ressourceURL
    }
 
    
    func testBasicData1() {
        let url = testDataURL(forResource:"BasicData1")
        
        do {
            try reader.parse(url: url!)
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
