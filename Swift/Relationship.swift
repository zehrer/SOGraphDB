//
//  Relationship.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

extension Relationship : Identiy, PropertyAccess {}

public struct Relationship : ValueStoreElement, Context {
    
    public weak var context : GraphContext! = nil
    
    public var uid: UID? = nil
    public var dirty = true
    
    var relationshipTypeNodeID: UID = 0
    
    public var nextPropertyID: UID  = 0
    
    var startNodeID: UID = 0
    var previousOutRelationID: UID = 0
    var nextOutRelationshipID: UID = 0   // same name as in Node
    
    
    var endNodeID: UID = 0
    var endNodePreviousRelationID: UID = 0
    var endNodeNextRelationID: UID = 0
    
    public init() {}
    
    public init (uid aID : UID) {
        uid = aID
    }
    
    public static func generateSizeTestInstance() -> Relationship {
        
        var result = Relationship()
        
        result.relationshipTypeNodeID = Int(UInt32.max)// TODO: interface?
        result.nextPropertyID = Int(UInt32.max)
        
        result.startNodeID = Int(UInt32.max)
        result.previousOutRelationID = Int(UInt32.max)
        result.nextOutRelationshipID = Int(UInt32.max)
        
        result.endNodeID = Int(UInt32.max)
        result.endNodePreviousRelationID = Int(UInt32.max)
        result.endNodeNextRelationID = Int(UInt32.max)
        
        return result
    }
    
    public init(coder decoder: Decode) {
        
        relationshipTypeNodeID = decoder.decode()
        nextPropertyID  = decoder.decode()
        
        startNodeID = decoder.decode()
        previousOutRelationID = decoder.decode()
        nextOutRelationshipID = decoder.decode()
        
        endNodeID = decoder.decode()
        endNodePreviousRelationID = decoder.decode()
        endNodeNextRelationID = decoder.decode()
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder : Encode) {
        encoder.encode(relationshipTypeNodeID)
        encoder.encode(nextPropertyID)
        
        encoder.encode(startNodeID)
        encoder.encode(previousOutRelationID)
        encoder.encode(nextOutRelationshipID)
        
        encoder.encode(endNodeID)
        encoder.encode(endNodePreviousRelationID)
        encoder.encode(endNodeNextRelationID)
    }
    
    // MARK: CRUD
    
    public mutating func delete() {
        context.delete(&self)
    }
    
    public mutating func update() {
        context.update(&self)
    }
}