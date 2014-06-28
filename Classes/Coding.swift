//
//  SOCoding.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

// NOT USED AT THE MOMENT

import Foundation

typealias UID = Int

protocol Identity {
    //var uid: UID? {get set} //identity
}

protocol Coding: Identity {
    
    var uid: UID? {get set} //identity
    
    // encoding
    var dirty: Bool {get set}
    func encodeData() -> NSData
    
    //encoding
    init(data: NSData)
}

@class_protocol
protocol Init {
    init()
}

@class_protocol
protocol ObjectCoding  {
    init()
    
    var uid: UID? {get set} //identity
    
    // encoding
    var dirty: Bool {get set}
    func encodeData() -> NSData
    
    //encoding
    init(data: NSData)
}

