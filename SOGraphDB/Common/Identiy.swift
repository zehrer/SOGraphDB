//
//  Identiy.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public typealias UID = Int // UInt32 don't save to much memory at the moment

public protocol Identiy {
    
    var uid: UID? {set get} //identity
    
    init (uid aID : UID)
}
