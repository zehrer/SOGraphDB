//
//  TestNode.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 21.06.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation


public class TestNode : PropertyAccessElement, ObjectStoreElement {

    public static func dataSize() -> Int {
        return 54  // 60?
    }

    // is required in the coding protocol
    public required init() {
    }
    
    public required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder: NSCoder) {

    }

}
