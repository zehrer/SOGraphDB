//
//  Relationship.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

public struct RELATIONSHIP : Init {
    var relationshipTypeNodeID: UID = 0;
    var nextPropertyID: UID  = 0;
    
    var startNodeID: UID = 0;
    var startNodePrevRelationID: UID = 0;
    var startNodeNextRelationID: UID = 0;
    
    var endNodeID: UID = 0;
    var endNodePrevRelationID: UID = 0;
    var endNodeNextRelationID: UID = 0;
    
    public init() {
        
    }
}

public func == (lhs: Relationship, rhs: Relationship) -> Bool {
    return lhs.uid == rhs.uid
}

public class Relationship : PropertyAccessElement, Coding, Equatable, NSCoding {
    
    //MARK: Data
    
    public var data: RELATIONSHIP = RELATIONSHIP()
    
    //MARK: NSCoding
    
    required public init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
        
        data.relationshipTypeNodeID = decoder.decodeIntegerForKey("1")
        data.nextPropertyID  = decoder.decodeIntegerForKey("2")
        
        data.startNodeID = decoder.decodeIntegerForKey("3")
        data.startNodePrevRelationID = decoder.decodeIntegerForKey("4")
        data.startNodeNextRelationID = decoder.decodeIntegerForKey("5")
        
        data.endNodeID = decoder.decodeIntegerForKey("6")
        data.endNodePrevRelationID = decoder.decodeIntegerForKey("7")
        data.endNodeNextRelationID = decoder.decodeIntegerForKey("8")
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeInteger(data.relationshipTypeNodeID, forKey:"1")
        encoder.encodeInteger(data.nextPropertyID, forKey:"2")
        
        encoder.encodeInteger(data.startNodeID, forKey:"3")
        encoder.encodeInteger(data.startNodePrevRelationID, forKey:"4")
        encoder.encodeInteger(data.startNodeNextRelationID, forKey:"5")
        
        encoder.encodeInteger(data.endNodeID, forKey:"6")
        encoder.encodeInteger(data.endNodePrevRelationID, forKey:"7")
        encoder.encodeInteger(data.endNodeNextRelationID, forKey:"8")
    }
    
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