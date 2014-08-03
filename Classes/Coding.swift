//
//  SOCoding.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

// NOT USED AT THE MOMENT

import Foundation

// BUG
// dont use inheritage for protocols, the compiler crash

public typealias UID = Int

public protocol Init {
    init()
}

public protocol DataStoreHeader {
    
    init()
    var used: Bool {get set};
}

@class_protocol
public protocol Coding {
    
    typealias DataType  : Init   
    
    var data: DataType {get set}
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
    
    //decoding NSData
    init(data: DataType)
}

@class_protocol
public protocol PersistentObject {
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
}





