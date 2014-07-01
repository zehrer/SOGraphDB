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

// BUG
// dont use inheritage for protocols, the compiler crash

protocol DataStoreHeader {
    
    init()
    var used: Bool {get set};
}

@class_protocol
protocol PersistentObject {
    
    typealias DataType  // : Init   
    
    init()
    
    var data: DataType {get set}
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    //decoding NSData
    init(data: DataType)
}


