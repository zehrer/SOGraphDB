//
//  Relationship.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 22.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Relationship : PropertyElement {

    let startNode : Node
    let endNode : Node
    
    var typeNodeID : UID? = nil
    
    public init(startNode aNode: Node, endNode bNode: Node) {
        startNode = aNode
        endNode = bNode
        
        super.init()
    }
    
    public func delete() {
        assert(graphStore != nil, "No GrapheStore available")
        
        //startNode.deleteOutRelationship(self)
        //endNode.deleteInRelationship(self)
            
        //graphStore.deleteRelationship(self)
        
    }
    
    public func setType(of node:Node) {
        self.typeNodeID = node.uid
    }
}

