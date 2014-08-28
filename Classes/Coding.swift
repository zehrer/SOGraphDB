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


//TODO: no init requirement any more !!
public protocol Init {
    init()
}

public protocol DataStoreHeader {

    var used: Bool {get set};
    
    init()
}

public protocol Coding : class {
    
    typealias DataType  : Init   
    
    var data: DataType {get set}
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
    
    //decoding NSData
    init(data: DataType)
}

public protocol PersistentObject : class {
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
}





