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
    
    
    /**
     No create -> later feature: auto register
     // create (and register) a new Node
     open func createNode() -> Node {
     let result = Node()
     register(node: result)
     return result;
     }
     */
    
    // register a (new created) Node to DB
    open func register(node aNode : Node) {
        aNode.graphStore = self.graphDBStore
        graphDBStore.register(aNode)
    }
    
    // delete/remove a (registered) Node from the DB
    open func delete(node aNode: Node) {
        graphDBStore.delete(aNode)
        aNode.graphStore = nil;
    }
    
    //MARK: data access
    
    public subscript(uid: UID) -> Node? {
        get {
            //assert(context != nil, "No GraphContext available")
            return graphDBStore.findNodeBy(uid: uid)
        }
    }
    
}
