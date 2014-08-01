//
//  Node.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

/**
protocol Node {
    
    // OUT
    var outRelationshipCount: Int? { get }
    var firstOutNode: Node? { get }
    var lastOutNode: Node? { get }
    
    var outRelationships: Relationship[] { get }
    
    func outRelationshipTo(node: Node) -> Relationship?
    
    func addOutRelationshipNode(node: Node) -> Relationship?
    func deleteOutRelationshipNode(node: Node)
    
    //func outNodeEnumerator() -> NSEnumerator
    
    
    // IN
    var inRelationshipCount: Int? { get }
    var firstInNode: Node? { get }
    var lastInNode: Node? { get }
    
    var inRelationships: Relationship[] { get }
    
    func inRelationshipFrom(node: Node) -> Relationship?
    
    func addInRelationshipNode(node: Node) -> Relationship?
    func deleteInRelationshipNode(node: Node)
    
    //func inNodeEnumerator() -> NSEnumerator
    
}
*/

struct NODE : Init {
    var nextPropertyID: UID = 0; // 4
    var nextOutRelationshipID: UID  = 0;  // 4
    var nextInRelationshipID: UID  = 0; // 4
    
    init() {
        
    }
}



class Node : GraphElement, Coding {

    var data: NODE = NODE()

    //var uid: UID? = nil
    //var dirty: Bool = true
    
    init() {
        
    }
    
    //decoding NSData
    init(data: NODE) {
        self.data = data
        
    }
    
    
    
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
    
    var outRelationships: [Relationship] {
    get {
        return [Relationship]()
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
    
    var inRelationships: [Relationship] {
    get {
        return [Relationship]()
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
