//
//  SOTestCase.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 21.01.18.
//

import XCTest

import Foundation


class SOTestCase: XCTestCase {
    
    // Add all test data files to the bundle
    func testDataURL(forResource res: String) -> URL? {
        let testBundle = Bundle(for: type(of: self))
        guard let ressourceURL = testBundle.url(forResource: res, withExtension: "xml") else {
            XCTFail("file does not exist")
            return nil
        }
        return ressourceURL
    }
    
}
