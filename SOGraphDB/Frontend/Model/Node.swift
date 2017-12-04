//
//  Node.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Node : PropertyAccessElement { //Equatable 

    public override init() {
        super.init()
    }
    
    /*
    public required init(uid aID: UID) {
        super.init(uid: aID)
    }
    */
    
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
    //   - the new relationship
    //   - (optional) the start node (itself) -> rel was appended directly
    //   - (optional) the start node lastRelationship -> the rel was appended
    //   - (optional) the end node - by calling insertInRelationship
    //   - (optional) the end node lastRelationship - by calling insertInRelationship
    // Why return optional?
    public func addOutRelationshipNode(endNode: Node) -> Relationship? {
        assert(graphStore != nil, "No GrapheStore available")
        
        let relationship =  Relationship(startNode: self, endNode: endNode)
        // TODO: implement self register
        
        graphStore.register(relationship: relationship)
        
        endNode.insert(inRelationship: relationship)
        
        self._outRelationships.append(relationship)
        
        
        /**
        if (context != nil) {
            // create an new realationship with a link to the this node
            let relationship =  Relationship(startNode: self) //[[SORelationship alloc] initWithStartNode:self];
            
            // create the ID of this new relationship without a CONTEXT WRITE
            // TODO: self registering??
            context!.registerRelationship(relationship)
            
            endNode.insertInRelationship(relationship)
            
            //NSMutableArray *outRelationships = [self outRelationshipArray];
            let outRelationships = self.outRelationships
            
            //SORelationship *lastRelationship = [outRelationships lastObject];
            let lastRelationship = outRelationships.last
            
            // TODO: optional chaining?
            if (lastRelationship != nil) {
                // it seems this node has already one or more relationships
                // add relationship to the last one
                relationship.startNodePreviousRelationID = lastRelationship!.uid!
                lastRelationship!.startNodeNextRelationID = relationship.uid!
                
                // updated of the LAST relationship is only required if
                // the is was extended
                // CONTEXT WRITE
                //[[self context] updateRelationship:lastRelationship];
                context!.updateRelationship(lastRelationship!)
                
            } else {
                // it seems this is the frist relationship
                // add relationship to the node
                //[self setOutRelationshipID:relationship.id];
                self.outRelationshipID = relationship.uid!
                
                // CONTEXT WRITE
                // update of self is only required if the id was set
                self.update()
            }
            
            // CONTEXT WRITE
            context!.updateRelationship(relationship)
            
            //[outRelationships addObject:relationship];
            _outRelationships.append(relationship)
            
            return relationship;
        }
 
        */
        
        return relationship
    }
    
    // MARK: IN
    
    // Update the _inRelationship
    // INFO: e.g. called by addOutRelationship
    func insert(inRelationship aRel: Relationship) {
        assert(graphStore != nil, "No GrapheStore available")
        
        _inRelationships.append(aRel)
        // TODO: improve details
        graphStore.update(node: self)
    }

}
