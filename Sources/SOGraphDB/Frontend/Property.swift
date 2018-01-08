//
//  File.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public struct Property {
    
    public var uid: UID!
    public var dirty: Bool = true
    
    //public var owner : PropertyAccess! = nil
    //public var keyNode : Node
    public var keyNodeID : UID
    
    //var isNodeSource: Bool = false;         // 3  <- yes = property of a node / no = property of a relationship
    
    //var sourceID: UID = 0  // the ID of the related node or relationship

    public init(keyNodeID: UID) {
        //self.keyNode = key
        self.keyNodeID = keyNodeID // key.uid
    }
    
    /**
    public init( related : PropertyAccess) {
        
        sourceID = related.uid!
        
        // default is false
        if related is Node {
            isNodeSource = true
        }
    }
    */

}
