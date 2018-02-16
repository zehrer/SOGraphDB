//
//  SOGrapheDB.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 13.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//
//  Feature List:
//  - Auto Register (TODO)
//
//

import Foundation

open class SOGrapheDB {
    
    private let graphDBStore : SOGraphDBStore
    
    //MARK:  -
    
    public init(store aStore: SOGraphDBStore) {
        self.graphDBStore = aStore
    }
    
    // register a (new created) Node to DB
    open func register(node aNode : Node) {
        //aNode.graphStore = self.graphDBStore
        graphDBStore.register(aNode)
    }
    
    // delete/remove a (registered) Node from the DB
    open func delete(node aNode: Node) {
        graphDBStore.delete(aNode)
        
    }
    
    //MARK: data access
    
    public subscript(uid: UID) -> Node? {
        get {
            //assert(context != nil, "No GraphContext available")
            return graphDBStore.findNodeBy(uid: uid)
        }
    }
    
    // Retreive existing node and if this is not found
    // create a new node with the specified uid
    public func obtainTypeNode(uid: UID) -> Node {
        if let result = graphDBStore.findNodeBy(uid: uid) {
            return result
        } else {
            return createNode(uid:uid)
        }
    }
    
    // only for internal usage
    func createNode(uid: UID) -> Node {
        let node = Node()
        node.uid = uid
        self.register(node: node)
        return node
    }
    
    /**
     No create -> later feature: auto register
     // create (and register) a new Node
     open func createNode() -> Node {
     let result = Node()
     register(node: result)
     return result;
     }
     */
}
