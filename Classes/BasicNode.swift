//
//  BasicNode.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

class BasicNode : Node {
    
    // OUT
    var outRelationshipCount: Int? {
        get {
            return 0;
        }
    }
    
    var firstOutNode: Node? {
        get {
            return nil;
        }
    }
    
    var lastOutNode: Node? {
        get {
            return nil;
        }
    }
    
    var outRelationships: Relationship[] {
        get {
            return Relationship[]()
        }
    }
    
    func outRelationshipTo(node: Node) -> Relationship? {
        return nil;
    }
    
    func addOutRelationshipNode(node: Node) -> Relationship? {
        return nil;
    }
    
    func deleteOutRelationshipNode(node: Node) {
        
    }
    
    /*
    func outNodeEnumerator() -> NSEnumerator {
        return SONodeEnumerator(
    }
    */
    
    
    // IN
    var inRelationshipCount: Int? {
        get {
            return 0;
        }
    }
    
    var firstInNode: Node? {
        get {
            return nil;
        }
    }
    
    var lastInNode: Node? {
        get {
            return nil;
        }
    }
    
    var inRelationships: Relationship[] {
        get {
            return Relationship[]()
        }
    }
    
    func inRelationshipFrom(node: Node) -> Relationship? {
        return nil;
    }
    
    func addInRelationshipNode(node: Node) -> Relationship? {
        return nil;
    }
    
    func deleteInRelationshipNode(node: Node) {
        
    }
    
    //func inNodeEnumerator() -> NSEnumerator
    
}