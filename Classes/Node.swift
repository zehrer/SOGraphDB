//
//  Node.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

public struct NODE : Init {
    var nextPropertyID: UID = 0 // 4
    var nextOutRelationshipID: UID  = 0;  // 4
    var nextInRelationshipID: UID  = 0; // 4
    
    public init() {
        
    }
}

public func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.uid == rhs.uid
}

public class Node : GraphElement, Coding, Equatable {
    
    // MARK: Coding

    public var data : NODE = NODE()
    
    
    // is required in the coding protocol
    required public init() {
    }

    //init with external value
    required public init(data: NODE) {
        //phase 1
        super.init()
        //phase 2
        self.data = data
        dirty = false
    }

    // MARK: OUT
    
    // only available for testing, not public
    var outRelationshipID : UID {
        get {
            return data.nextOutRelationshipID
        }
        set {
            if newValue != data.nextOutRelationshipID {
                data.nextOutRelationshipID = newValue
                dirty = true
            }
        }
    }
    
    var _outRelationships:[Relationship]! = nil
    
    public var outRelationships: [Relationship] {
        get {
            if (_outRelationships == nil) {
                _outRelationships = [Relationship]()
                
                // read data
                var relationship:Relationship! = nil;
                var nextRelationshipID = data.nextOutRelationshipID;
                
                while (nextRelationshipID > 0) {
                    
                    relationship = context.readRelationship(nextRelationshipID)
                    
                    _outRelationships.append(relationship)
                    
                    nextRelationshipID = relationship.startNodeNextRelationID
                }
            }
            
            return _outRelationships;
        }
    }
    
    var outRelationshipCount: Int {
        get {
            return outRelationships.count
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
    
    //find out relationship on disc
    // TODO: this version is migrated from SONode
    // improve the implementation e.g. reuse the informarion form outRelationships
    func outRelationshipTo(endNode: Node) -> Relationship? {
        // read data
        var relationship:Relationship! = nil;
        var nextRelationshipID = outRelationshipID
        
        while (nextRelationshipID > 0) {
            
            relationship = context.readRelationship(nextRelationshipID)
            
            if (relationship.endNodeID == endNode.uid) {
                return relationship;
            }
            
            nextRelationshipID = relationship.startNodeNextRelationID
        }
        
        return nil;
    }
    
    // Create a new relation add it to the start node (this node) and the end node
    // This methode update
    //   - the new relationship
    //   - (optional) the start node (itself) -> rel was appended directly
    //   - (optional) the start node lastRelationship -> the rel was appended
    //   - (optional) the end node - by calling insertInRelationship
    //   - (optional) the end node lastRelationship - by calling insertInRelationship
    func addOutRelationshipNode(endNode: Node) -> Relationship? {
        
        if (context != nil) {
            // create an new realationship with a link to the this node
            var relationship =  Relationship(startNode: self) //[[SORelationship alloc] initWithStartNode:self];
            
            // create the ID of this new relationship without a CONTEXT WRITE
            // TODO: self registering??
            context.registerRelationship(relationship)
            
            endNode.insertInRelationship(relationship)
            
            //NSMutableArray *outRelationships = [self outRelationshipArray];
            var outRelationships = self.outRelationships
            
            //SORelationship *lastRelationship = [outRelationships lastObject];
            var lastRelationship = outRelationships.last
            
            // TODO: optional chaining?
            if (lastRelationship != nil) {
                // it seems this node has already one or more relationships
                // add relationship to the last one
                relationship.startNodePreviousRelationID = lastRelationship!.uid
                lastRelationship!.startNodeNextRelationID = relationship.uid
                
                // updated of the LAST relationship is only required if
                // the is was extended
                // CONTEXT WRITE
                //[[self context] updateRelationship:lastRelationship];
                context.updateRelationship(lastRelationship!)
                
            } else {
                // it seems this is the frist relationship
                // add relationship to the node
                //[self setOutRelationshipID:relationship.id];
                self.outRelationshipID = relationship.uid
                
                // CONTEXT WRITE
                // update of self is only required if the id was set
                self.update()
            }
            
            // CONTEXT WRITE
            context.updateRelationship(relationship)
            
            //[outRelationships addObject:relationship];
            outRelationships.append(relationship)
            
            return relationship;
        }
        
        return nil;
    }
    
    // Delete a existing relationship between this node (start node) and the specified node (end node)
    func deleteOutRelationshipNode(endNode: Node) {
        
        var relationship = self.outRelationshipTo(endNode)
        if (relationship != nil) {
            relationship!.delete()
        }
        
    }
    
    func deleteOutRelationship(aRelationship:Relationship) {
        var previousRelationship:Relationship! = nil
        var nextRelationship:Relationship! = nil
        
        var nextRelationshipID = aRelationship.startNodeNextRelationID
        var previousRelationshipID = aRelationship.startNodePreviousRelationID
        
        if (nextRelationshipID > 0) {
            nextRelationship = context.readRelationship(nextRelationshipID)
            
            nextRelationship.startNodePreviousRelationID = previousRelationshipID
            
            // CONTEXT WRITE
            context.updateRelationship(nextRelationship)
        }
        
        if (previousRelationshipID > 0) {
            previousRelationship = context.readRelationship(previousRelationshipID)
            
            previousRelationship.startNodeNextRelationID = nextRelationshipID
            
            // CONTEXT WRITE
            context.updateRelationship(previousRelationship)
            
        } else {
            // seems this is the first relationship in the chain
            outRelationshipID = nextRelationshipID
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        var index = find(outRelationships, aRelationship) // init outRelationships in worst case
        _outRelationships.removeAtIndex(index!)
    }


    /*
    func outNodeEnumerator() -> NSEnumerator {
    return SONodeEnumerator(
    }
    */
    
    
    // MARK: IN
    
    // only available for testing, not public
    var inRelationshipID : UID {
        get {
            return data.nextInRelationshipID
        }
        set {
            if newValue != data.nextInRelationshipID {
                data.nextInRelationshipID = newValue
                dirty = true
            }
        }
    }
    
    var _inRelationships:[Relationship]! = nil
    
    public var inRelationships: [Relationship] {
        get {
            if (_inRelationships == nil) {
                _inRelationships = [Relationship]()
                
                // read data
                var relationship:Relationship! = nil
                var nextRelationshipID = data.nextInRelationshipID
                
                while (nextRelationshipID > 0) {
                    
                    relationship = context.readRelationship(nextRelationshipID)
                    
                    _inRelationships.append(relationship)
                    
                    nextRelationshipID = relationship.endNodeNextRelationID
                }
            }
            
            return _inRelationships;
        }
    }

    
    var inRelationshipCount: Int? {
        get {
            return 0;
        }
    }
    
    var firstInNode: Node? {
        get {
            
            if (context != nil) {
                
                var relationship = context.readRelationship(inRelationshipID)
                
                if (relationship != nil) {
                    return context.readNode(relationship!.startNodeID)
                }
            }
            return nil
        }
    }
    
    var lastInNode: Node? {
        get {
            if (context != nil) {
                
                var relationship = inRelationships.last
                
                if (relationship != nil) {
                    return context.readNode(relationship!.startNodeID)
                }
            }

            return nil
        }
    }
    
    func inRelationshipFrom(node: Node) -> Relationship? {
        return nil
    }
    
    func addInRelationshipNode(node: Node) -> Relationship? {
        return nil
    }
    
    func deleteInRelationshipNode(node: Node) {
        
    }
    
    // Update the ID's of the NEW specified IN relationship
    // This method update
    //  - optional : the end node (itself) -> rel was appended directly
    //  - optional : the lastRelationship if the rel was appended
    // INFO: e.g. called by addOutRelationship
    func insertInRelationship(relationship: Relationship) {
        
        // view from then endNode
        relationship.endNodeID = self.uid;
        
        //NSMutableArray *inRelationships = [self inRelationshipArray];
        
        var lastRelationship = inRelationships.last
        
        if (lastRelationship != nil) {
            // it seems this node has already one or more relationships
            // add relationship to the last one
            relationship.endNodePreviousRelationID = lastRelationship!.uid
            lastRelationship!.endNodeNextRelationID = relationship.uid
            
            // CONTEXT
            context.updateRelationship(lastRelationship!)
        } else {
            // it seems the new relationship is the frist one
            // add relationship to the node
            inRelationshipID = relationship.uid
            
            // CONTEXT
            self.update()
        }
        
        _inRelationships.append(relationship)
    }

    func deleteInRelationship(aRelationship:Relationship) {
        var previousRelationship : Relationship! = nil;
        var nextRelationship : Relationship! = nil;
        
        var nextRelationshipID = aRelationship.endNodeNextRelationID
        var previousRelationshipID = aRelationship.endNodePreviousRelationID
        
        if (nextRelationshipID > 0) {
            nextRelationship = context.readRelationship(nextRelationshipID)
            
            nextRelationship.endNodePreviousRelationID = previousRelationshipID
            
            // CONTEXT WRITE
            context.updateRelationship(nextRelationship)
        }
        
        if (previousRelationshipID > 0 ) {
            previousRelationship = context.readRelationship(previousRelationshipID)
            
            previousRelationship.endNodeNextRelationID = nextRelationshipID
            
            // CONTEXT WRITE
            context.updateRelationship(previousRelationship)
            
        } else {
            // seems this is the first relationship in the chain
            self.inRelationshipID = nextRelationshipID
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        var index = find(inRelationships, aRelationship) // init outRelationships in worst case
        _inRelationships.removeAtIndex(index!)
        
    }
    
    //func inNodeEnumerator() -> NSEnumerator
    //  return [[SONodeEnumerator alloc] initWithNode:self];

    // MARK: Related (OUT) Nodes
    
    func relatedNodes() -> [Node] {
        
        var result = [Node]()
        
        if (context != nil) {
            // UseCase: new (in context) -> isDiry = false && context != nil  (if the context store directly)
            // Usecase: updated (in context) -> isDiry =
            // TODO: updated this text
            
            let outArray = outRelationships
            
            for relationship in outArray {
                var aNode = context.readNode(relationship.endNodeID)
                if (aNode != nil) {
                    result.append(aNode!)
                }
            }
        }
        
        return result
    }
    
    
    // MARK: ???
    // TODO: define a protocol?
    
    func update() {
        self.context.updateNode(self)
    }
    
    // MARK: Property
    var propertyID : UID {
        get {
            return data.nextPropertyID
        }
        set {
            if newValue != data.nextPropertyID {
                data.nextPropertyID = newValue
                dirty = true
            }
        }
    }
}
