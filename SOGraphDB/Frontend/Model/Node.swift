//
//  Node.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Node : PropertyAccessElement { //Equatable 

    public override init() {
        super.init()
    }
    
    /*
    public required init(uid aID: UID) {
        super.init(uid: aID)
    }
    */
    
    // MARK: OUT
    
    var _outRelationships:[Relationship]! = nil
    
    public var outRelationships: [Relationship] {
        get {
            if (_outRelationships == nil) {
                _outRelationships = [Relationship]()
                
                //assert(context != nil, "No GraphContext available")
                
                // read data
                //TODO ???
                
            }
    
            return _outRelationships;
        }
    }
    
    public var outRelationshipCount: Int {
        get {
            return outRelationships.count
        }
    }
    
    // find out relationship
    public func outRelationshipTo(endNode: Node) -> Relationship? {
        //assert(context != nil, "No GraphContext available")
        
        return graphStore.findRelationship(from: self, to:endNode)
    }

}
