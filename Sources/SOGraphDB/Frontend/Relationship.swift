//
//  Relationship.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 22.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Relationship : Node {

    let startNode : Node
    let endNode : Node
    
    
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

    // MARK: - (static) Type System
    
    // todo store as property :)
    var typeNodeID : UID? = nil
    
    // Defines that the startNode is an instance of the "class" endNode
    // NodeA --type--> NodeB
    // similar to rdf:type
    public func setTypeRelationship() {
        self.typeNodeID = 0
    }

    public override func setType(of node:Node) {
        self.typeNodeID = node.uid
        
        
    }
    
    public func getType() -> Node? {
        return self.graphStore.findNodeBy(uid: self.typeNodeID)
    }
    
    public func getTypeID() -> UID? {
        return self.typeNodeID
    }

    
}

