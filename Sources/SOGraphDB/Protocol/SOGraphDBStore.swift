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
    init()
    // NSDocument use more flexible url's 
    //init(url: URL) throws
    //
    
    // register a node
    //
    // this method is usually called to register a new node or register a existing persistent node
    // if the UID is already set, it replace the existing node by the new one
    // and return the old node 
    @discardableResult func register(_ aNode : Node) -> Node?
    
    // find Node by ID.
    // if UID is nil this function return nil (simpfly optinal handling)
    func findNodeBy(uid: UID?) -> Node?
    
    func update(_ aNode: Node)
    func delete(_ aNode: Node)
    
    func register(_ aRelationship: Relationship)
    func update(_ aRelationship: Relationship)
    func delete(_ aRelationship: Relationship)
    
    func findRelationship(from startNode:Node, to endNode:Node) -> Relationship?
    
    
    // TOOD: Properties?
    
    
}
