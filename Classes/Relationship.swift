//
//  Relationship.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

public struct RELATIONSHIP : Init {
    var relationshipTypeNodeID: UID = 0; // 4
    var nextPropertyID: UID  = 0;  // 4
    
    var startNodeID: UID = 0; // 4
    var startNodePrevRelationID: UID = 0; // 4
    var startNodeNextRelationID: UID = 0; // 4
    
    var endNodeID: UID = 0; // 4
    var endNodePrevRelationID: UID = 0; // 4
    var endNodeNextRelationID: UID = 0; // 4
    
    public init() {
        
    }
}

public func == (lhs: Relationship, rhs: Relationship) -> Bool {
    return lhs.uid == rhs.uid
}

public class Relationship : PropertyAccessElement, Coding, Equatable {
    
    public var data: RELATIONSHIP = RELATIONSHIP()
    
    public required init() {
    }
    
    //init with external value
    required public init(data: RELATIONSHIP) {
        //phase 1
        self.data = data
        super.init()
        //phase 2
        dirty = false
    }
    
    required public init(startNode:Node) {
        super.init()
        data.startNodeID = startNode.uid
        //dirty = true
    }
    
    // MARK: StartNode

    func startNode() -> Node? {
        if (context != nil) {
           return context.readNode(startNodeID)
        }
        return nil
    }
    
    var startNodeID : UID {
        get {
            return data.startNodeID
        }
        set {
            if (newValue != data.startNodeID) {
                data.startNodeID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var startNodePreviousRelationID : UID {
        get {
            return data.startNodePrevRelationID
        }
        set {
            if newValue != data.startNodePrevRelationID {
                data.startNodePrevRelationID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var startNodeNextRelationID : UID {
        get {
            return data.startNodeNextRelationID
        }
        set {
            if newValue != data.startNodeNextRelationID {
                data.startNodeNextRelationID = newValue
                dirty = true
            }
        }
    }
    
    // MARK: EndNode
    
    func endNode() -> Node? {
        if (context != nil) {
            return context.readNode(endNodeID)
        }
        return nil
    }
    
    var endNodeID : UID {
        get {
            return data.endNodeID
        }
        set {
            if (newValue != data.endNodeID) {
                data.endNodeID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var endNodePreviousRelationID : UID {
        get {
            return data.endNodePrevRelationID
        }
        set {
            if newValue != data.endNodePrevRelationID {
                data.endNodePrevRelationID = newValue
                dirty = true
            }
        }
    }
    
    // only available for testing, not public
    var endNodeNextRelationID : UID {
        get {
            return data.endNodeNextRelationID
        }
        set {
            if newValue != data.endNodeNextRelationID {
                data.endNodeNextRelationID = newValue
                dirty = true
            }
        }
    }
    
    // MARK: PropertyAccessElement
    
    override var propertyID : UID {
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
    
    override func update() {
        context.updateRelationship(self)
    }
    
    func delete() {
        if (self.context != nil ) {
            var startNode = context.readNode(data.startNodeID)
            var endNode = context.readNode(data.endNodeID)
            
            startNode!.deleteOutRelationship(self)
            endNode!.deleteInRelationship(self)
            
            context.deleteRelationship(self)
        }
    }

}