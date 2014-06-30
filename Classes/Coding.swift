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
    var uid: UID? {get set} //identity
}


protocol Init {
    init()
}

// for St
protocol Coding {
    
    func encodeData() -> NSData
    
    func decodeData(aData: NSData)
}


protocol DataStoreHeader : Init {
    var used: Bool {get set};
}


@class_protocol
protocol PersistentObject {
    
    typealias DataType
    
    var data: DataType {get set}
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
}




@class_protocol
protocol ObjectCoding  {
    init()
    
    var uid: UID? {get set} //identity
    
    // encoding NSDATA
    var dirty: Bool {get set}
    func encodeData() -> NSData
    
    //decoding NSData
    init(data: NSData)
}

