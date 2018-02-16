//
//  TestDBStore.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 16.02.18.
//

import Foundation
import SOGraphDB

public class TestDBStore : SOGraphDBStore {
    
    public required init()  {
    }
    
    @discardableResult public func register(_ aNode: Node) -> Node? {
        aNode.graphStore = self
        
        return nil
    }
    
    public func findNodeBy(uid: UID?) -> Node? {
        return nil
    }
    
    public func update(_ aNode: Node) {
        
    }
    
    public func delete(_ aNode: Node) {
        
    }
    
    public func register(_ aRelationship: Relationship) {
        
    }
    
    public func update(_ aRelationship: Relationship) {
        
    }
    
    public func delete(_ aRelationship: Relationship) {
        
    }
    
    public func findRelationship(from startNode: Node, to endNode: Node) -> Relationship? {
        return nil
    }

}

