//
//  Node.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Node : Hashable {
    
    // TODO: improve basic type sytem
    // uid = 0 is reserved for instanceOf type
    static var maxUID : UID = 1

    //Equatable

    public  init() {
        Node.maxUID += 1
        self.uid = Node.maxUID
    }
    
    public init(uid: UID) {
        self.uid = uid
        Node.maxUID = max(Node.maxUID,uid)
    }
    
    public convenience init(type : Node) {
        self.init()
        setType(of: type)
    }
    
    // MARK: OUT
    
    // direct access in the insert methode !!
    lazy var _outRelationships = [Relationship]()
    
    public var outRelationships: [Relationship] {
        get {
            /**
            if (_outRelationships == nil) {
                _outRelationships = [Relationship]()
                
                // read data
                // //assert(graphStore != nil, "No GraphContext available")
                //TODO ???
            }
            */
            return _outRelationships;
        }
    }
    
    public func outNodes(type : Node? = nil) -> [Node] {
        var result = [Node]()
        for rel in _outRelationships {
            if type != nil {
                // add only a specifc type to the result
                /**
                 // TODO
                if rel.typeNodeID == type!.uid {
                  result.append(rel.endNode)
                }
                */
            } else {
                // add all nodes to the result
                 result.append(rel.endNode)
            }
        }
        
        return result
    }
    
    public var outRelationshipCount: Int {
        get {
            return outRelationships.count
        }
    }
    
    // find out relationship
    @discardableResult public func outRelationshipTo(endNode: Node) -> Relationship? {
        assert(graphStore != nil, "No GrapheStore available")
        
        return graphStore.findRelationship(from: self, to:endNode)
    }
    
    // Create a new relation add it to the start node (this node) and the end node
    // This methode update
    //   - create and register a new relationship
    //   - add the relationship to the itself (call insert)
    //   - add the relationship to the end node (call insert)
    // TODO: the old version the return value was optional, why?
    @discardableResult public func addOutRelationshipTo(endNode: Node) -> Relationship {
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
    
    // direct access in the insert methode !!
    lazy var _inRelationships = [Relationship]()
    
    public var inRelationships: [Relationship] {
        get {
            /**
            if (_inRelationships == nil) {
                _inRelationships = [Relationship]()
                
                // read data
                // //assert(graphStore != nil, "No GraphContext available")
                //TODO ???
            }
            */
            return _inRelationships;
        }
    }
    
    public var inRelationshipCount: Int {
        get {
            return inRelationships.count
        }
    }
    
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
    
    
    // MARK: - type system
    
    public func setType(of type:Node) {
       
        let rel = self.addOutRelationshipTo(endNode: type)
        // TODO
        //rel.setTypeRelationship()
    }
    
    // Mark: - former Property Element part
    
    public var uid: UID!
    public var graphStore: SOGraphDBStore!
    public var dirty: Bool = true
    
    lazy var properties = [UID : Property]()
    

    // MARK: - Hashable
    
    public var hashValue: Int {
        get{
            return uid.hashValue
        }
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    // MARK: -
    
    public func onAllProperties(_ closure: (Property) -> Void) {
        for property in properties.values {
            closure(property)
        }
    }
    
    public subscript(keyNode: Node) -> Property {
        get {
            //assert(context != nil, "No GraphContext available")
            if let result = properties[keyNode.uid] {
                return result
            } else {
                return createPropertyFor(keyNode)
            }
        }
    }
    
    public subscript(keyNodeID : UID) -> Property {
        get {
            if let result = properties[keyNodeID] {
                return result
            } else {
                return createPropertyForKeyNode(uid: keyNodeID)
            }
        }
        set(newValue) {
            properties[keyNodeID] = newValue
        }
    }
    
    func createPropertyForKeyNode(uid: UID) -> Property {
        let property = Property(keyNodeID: uid)
        properties[uid] = property
        return property
    }
    
    // Create a new property and add it to this element
    // This methode update
    //   - (optional) the lastProperty -> the property was appended directly
    //   - (optional) the element  -> the property was appended
    // PreConditions: Element is in a context
    func createPropertyFor(_ keyNode: Node) -> Property {
        //assert(context != nil, "No GraphContext available")
        //assert(keyNode.uid != nil, "KeyNode without a uid")
        
        
        //var property = Property(related: self)
        let property = Property(keyNodeID: keyNode.uid)
        //property.related =
        //property.keyNodeID = keyNode.uid!
        
        //context.registerProperty(&property)
        //context.updateProperty(property)
        //append(&property)
        
        properties[keyNode.uid] = property
        
        return property
    }
    
    /**
     public func propertyByKey(_ keyNode: Node) -> Property? {
     
     if properties.isEmpty {
     return nil
     }
     
     return properties[keyNode.uid!]
     }
     */
    
    public func propertyByKeyNodeID(uid: UID) -> Property? {
        return properties[uid]
    }
    
}
