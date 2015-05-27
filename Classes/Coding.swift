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

public typealias UID = Int // UInt32 don't save to much memory at the moment


//TODO: no init requirement any more !!
public protocol Init {
    init()
}

// TODO: try to define protocol as NOT public
public protocol DataStoreHeader {

    var used: Bool {get set};
    
    init()
}

// TODO: try to define protocol as NOT public
public protocol Coding : class {
    
    typealias DataType : Init
    
    var data: DataType {get set}
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
    
    //setup the object with external data
    init(data: DataType)
}

protocol PersistentObject : class {
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
}





