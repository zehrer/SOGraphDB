//
//  File.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public struct Property {
    
    //public var uid: UID!
    
    public var dirty: Bool = true
    
    var isNodeSource: Bool = false;         // 3  <- yes = property of a node / no = property of a relationship
    
    var sourceID: UID = 0  // the ID of the related node or relationship
    var keyNodeID: UID = 0

    
    public init( related : PropertyAccess) {
        
        sourceID = related.uid!
        
        // default is false
        if related is Node {
            isNodeSource = true
        }
    }
    
}
