//
//  TestData.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 05.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation
import SOGraphDB

let testStringUTF8   = "01234567890123456789"
let testStringUTF8U1 = "98765432109876543210"               //20  use case 1 update: same size
let testStringUTF8U2 = "987654321098"                       //12  use case 2 update: smaller size
let testStringUTF8U3 = "987654321098765432109876543210"     //30  use case 3 update: larger size
let testStringUTF8U4 = "012345678901234567890123"           //24  use case 3 update: larger size
let testStringUTF16  = "\u{6523}\u{6523}\u{6523}\u{6523}"   //10  should be better in UTF16 as in UTF8

class EmptyClass : NSObject, NSCoding {
    
    //MARK: SOCoding
    
    @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
    }
    
    @objc func encode(with encoder: NSCoder) {
    }
    
    static func dataSize() -> Int {
        return 0
    }
    
    override required init() {
        
    }
    
    var uid: UID?
    var dirty: Bool = true
}

class B : NSObject, NSCoding {
    
    //MARK: SOCoding
    
    @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
    }
    
    @objc func encode(with encoder: NSCoder) {
    }
    
    static func dataSize() -> Int {
        return 0
    }
    
    override required init() {
        
    }
    
    var uid: UID?
    var dirty: Bool = true
}

class TestClass : NSObject, NSCoding {
    
    var a : Int = 0
    
    var uid: UID?
    var dirty: Bool = true
    
    var num : Int {
        get {
            return self.a
        }
    }
    
    override required init() {
        // data = TestData()
    }
    
    init (num : Int) {
        // data = TestData()
        a = num
    }
    
    //MARK: NSCoding
    //public func encodeWithCoder(aCoder: NSCoder)
    //public init?(coder aDecoder: NSCoder) // NS_DESIGNATED_INITIALIZER
    
    @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
        
        a  = decoder.decodeInteger(forKey: "1")
    }
    
    @objc func encode(with encoder: NSCoder) {
        encoder.encode(a, forKey: "1")
    }
    
    static func dataSize() -> Int {
        return 68
    }
    
}
