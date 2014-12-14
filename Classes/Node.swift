//
//  Node.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

struct NODE : Init {
    var nextPropertyID: UID = 0 // 4
    var nextOutRelationshipID: UID  = 0;  // 4
    var nextInRelationshipID: UID  = 0; // 4
    
    init() {
        
    }
}

class Node : GraphElement, Coding {
    
    // MARK: Coding

    var data : NODE = NODE()
    
    // is required in the coding protocol
    override required init() {
        
    }

    //decoding NSData
    required init(data: NODE) {
        self.data = data
        //dirty = false
    }

    // MARK: OUT
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
    
    
    // MARK: IN
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
    

    // MARK: ??
    
    func update() {
        self.context.updateNode(self)
    }
    
    // MARK: Property
    var propertyID : UID? {
        get {
            return data.nextPropertyID
        }
        set(newID) {
            if newID != data.nextPropertyID {
                if (newID != nil) {
                    data.nextPropertyID = newID!
                } else {
                    data.nextPropertyID = 0
                }
                dirty = true
            }
        }
    }
}
