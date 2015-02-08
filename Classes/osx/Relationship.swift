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

public class Relationship : GraphElement, Coding {
    
    public var data: RELATIONSHIP = RELATIONSHIP()
    
    public required init() {
    }
    
    //init with external value
    required public init(data: RELATIONSHIP) {
        //phase 1
        super.init()
        //phase 2
        self.data = data
        dirty = false
    }
    
    required public init(startNode:Node) {
        super.init()
        
        //TODO: implement
    }
    
    // MARK: StartNode
    
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

}