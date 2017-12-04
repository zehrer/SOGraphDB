//
//  SOGrapheDBStore.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol SOGraphDBStore {
    
    // URL: reference to the GrapheDB data file(s)
    init(url: URL) throws
    
    func register(node aNode : Node)
    func update(node aNode: Node)
    func delete(node aNode: Node)
    
    func register(relationship aRelationship: Relationship)
    func update(relationship aRelationship: Relationship)
    func delete(relationship aRelationship: Relationship)
    
    func findRelationship(from startNode:Node, to endNode:Node) -> Relationship?
    
}
