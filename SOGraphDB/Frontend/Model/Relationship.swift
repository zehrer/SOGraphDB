//
//  Relationship.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 22.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Relationship : PropertyAccessElement {

    let startNode : Node
    let endNode : Node
    
    public required init(startNode aNode: Node, endNode bNode: Node) {
        startNode = aNode
        endNode = bNode
    }
    
    
}

