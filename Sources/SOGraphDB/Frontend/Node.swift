//
//  Node.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Node : PropertyElement, Hashable {
    
    static var maxUID : UID = 0

    //Equatable

    public override init() {
        super.init()
    }
    
    public override init(uid: UID) {
        super.init(uid: uid)
        Node.maxUID = max(Node.maxUID,uid) + 1
    }
    
    // MARK : Hashable
    
    public var hashValue: Int {
        get{
            return uid.hashValue
        }
    }
    
    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    // MARK: Relationships
    
    var _outRelationships:[Relationship]! = nil
    var _inRelationships:[Relationship]! = nil
    
    // MARK: OUT
    
    public var outRelationships: [Relationship] {
        get {
            if (_outRelationships == nil) {
                _outRelationships = [Relationship]()

                
                
                // read data
                // //assert(graphStore != nil, "No GraphContext available")
                //TODO ???
            }
            return _outRelationships;
        }
    }
    
    public var outRelationshipCount: Int {
        get {
            return outRelationships.count
        }
    }
    
    // find out relationship
    public func outRelationshipTo(endNode: Node) -> Relationship? {
        assert(graphStore != nil, "No GrapheStore available")
        
        return graphStore.findRelationship(from: self, to:endNode)
    }
    
    // Create a new relation add it to the start node (this node) and the end node
    // This methode update
    //   - create and register a new relationship
    //   - add the relationship to the itself (call insert)
    //   - add the relationship to the end node (call insert)
    // TODO: the old version the return value was optional, why?
    public func addOutRelationshipTo(endNode: Node) -> Relationship {
        assert(graphStore != nil, "No GrapheStore available")
        
        let relationship =  Relationship(startNode: self, endNode: endNode)
        // TODO: implement self register
        graphStore.register(relationship)
        
        endNode.insert(inRelationship: relationship)
        self.insert(outRelationship: relationship)
        
        return relationship
    }
    
    // Delete a existing relationship between this node (start node) and the specified end node
    public func deleteOutRelationshipTo(endNode: Node) {
        assert(graphStore != nil, "No GrapheStore available")
        
        let relationship = self.outRelationshipTo(endNode: endNode)
        
        if (relationship != nil) {
            relationship!.delete()
        }
        
    }
    
    /**
    func delete(outRelationship aRel: Relationship)  {

        
        let nextRelationshipID = aRelationship.startNodeNextRelationID
        let previousRelationshipID = aRelationship.startNodePreviousRelationID
        
        if (nextRelationshipID > 0) {
            nextRelationship = context!.readRelationship(nextRelationshipID)
            
            nextRelationship.startNodePreviousRelationID = previousRelationshipID
            
            // CONTEXT WRITE
            context!.updateRelationship(nextRelationship)
        }
        
        if (previousRelationshipID > 0) {
            previousRelationship = context!.readRelationship(previousRelationshipID)
            
            previousRelationship.startNodeNextRelationID = nextRelationshipID
            
            // CONTEXT WRITE
            context!.updateRelationship(previousRelationship)
            
        } else {
            // seems this is the first relationship in the chain
            outRelationshipID = nextRelationshipID
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        //let index = find(outRelationships, aRelationship)// init outRelationships in worst case
        let index = outRelationships.indexOf(aRelationship)
        if let index = index {
            _outRelationships.removeAtIndex(index)
        }
    }
    */
    
    
    // Update the outRelationship and notify the graphStore
    func insert(outRelationship aRel: Relationship) {
        assert(graphStore != nil, "No GrapheStore available")
        
        _outRelationships.append(aRel)
        // TODO: improve details
        graphStore.update(self)
    }
    
    // MARK: IN
    
    // Create a new relation add it to the start node and the end node (this node)
    // This methode update
    //   - create and register a new relationship
    //   - add the relationship to the start node (call insert)
    //   - add the relationship to the itself (call insert)
    public func addInRelationshipFrom(startNode: Node) -> Relationship {
        assert(graphStore != nil, "No GrapheStore available")
        
        let relationship =  Relationship(startNode: startNode, endNode: self)
        // TODO: implement self register
        graphStore.register(relationship)
        
        self.insert(inRelationship: relationship)
        startNode.insert(outRelationship: relationship)
        
        return relationship
    }
    
    
    // Update the inRelationship and notify the graphStore
    func insert(inRelationship aRel: Relationship) {
        assert(graphStore != nil, "No GrapheStore available")
        
        _inRelationships.append(aRel)
        // TODO: improve details
        graphStore.update(self)
    }

}
