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
    var parser : GXLReader!
    
    override func setUp() {
        super.setUp()
        
        xmlFileStore = XMLFileStore()
        parser = GXLReader(store: xmlFileStore)
    }
    
    func testExample() {
        let url = URL(string: "../TestData/BasicData1.xml")
        
        do {
            try parser.parse(url: url!)
        } catch {
            print(error)
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
