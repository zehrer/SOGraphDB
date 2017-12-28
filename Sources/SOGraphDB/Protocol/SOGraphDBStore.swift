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
    
    func register(_ aNode : Node)
    func update(_ aNode: Node)
    func delete(_ aNode: Node)
    
    func register(_ aRelationship: Relationship)
    func update(_ aRelationship: Relationship)
    func delete(_ aRelationship: Relationship)
    
    func findRelationship(from startNode:Node, to endNode:Node) -> Relationship?
    
}
