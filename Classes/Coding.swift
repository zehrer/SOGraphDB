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

protocol Init {
    init()
}

protocol Identity {
    var uid: UID? {get set} //identity
}

protocol Coding: Init, Identity {
    
    // encoding
    var dirty: Bool {get set}
    func encodeData() -> NSData
    
    //encoding
    init(data: NSData)
}


@class_protocol
protocol ObjectCoding : Coding {

    
}

