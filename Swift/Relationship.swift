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
    
    var relationshipTypeNodeID: UID = 0 {
        didSet {
            if relationshipTypeNodeID != oldValue {
                dirty = true
            }
        }
    }
    
    public var nextPropertyID: UID  = 0 {
        didSet {
            if nextPropertyID != oldValue {
                dirty = true
            }
        }
    }
    
    var startNodeID: UID = 0 {
        didSet {
            if startNodeID != oldValue {
                dirty = true
            }
        }
    }
    
    var startNodePreviousRelationID: UID = 0 {
        didSet {
            if startNodePreviousRelationID != oldValue {
                dirty = true
            }
        }
    }
    
    var startNodeNextRelationID: UID = 0 {
        didSet {
            if startNodeNextRelationID != oldValue {
                dirty = true
            }
        }
    }
    
    var endNodeID: UID = 0 {
        didSet {
            if endNodeID != oldValue {
                dirty = true
            }
        }
    }

    var endNodePreviousRelationID: UID = 0 {
        didSet {
            if endNodePreviousRelationID != oldValue {
                dirty = true
            }
        }
    }

    var endNodeNextRelationID: UID = 0 {
        didSet {
            if endNodeNextRelationID != oldValue {
                dirty = true
            }
        }
    }
    
    public init() {}
    
    public init (uid aID : UID) {
        uid = aID
    }
    
    public static func generateSizeTestInstance() -> Relationship {
        
        var result = Relationship()
        
        result.relationshipTypeNodeID = Int(UInt32.max)// TODO: interface?
        result.nextPropertyID = Int(UInt32.max)
        
        result.startNodeID = Int(UInt32.max)
        result.startNodePreviousRelationID = Int(UInt32.max)
        result.startNodeNextRelationID = Int(UInt32.max)
        
        result.endNodeID = Int(UInt32.max)
        result.endNodePreviousRelationID = Int(UInt32.max)
        result.endNodeNextRelationID = Int(UInt32.max)
        
        return result
    }
    
    public init(coder decoder: Decode) {
        
        relationshipTypeNodeID = decoder.decode()
        nextPropertyID  = decoder.decode()
        
        startNodeID = decoder.decode()
        startNodePreviousRelationID = decoder.decode()
        startNodeNextRelationID = decoder.decode()
        
        endNodeID = decoder.decode()
        endNodePreviousRelationID = decoder.decode()
        endNodeNextRelationID = decoder.decode()
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder : Encode) {
        encoder.encode(relationshipTypeNodeID)
        encoder.encode(nextPropertyID)
        
        encoder.encode(startNodeID)
        encoder.encode(startNodePreviousRelationID)
        encoder.encode(startNodeNextRelationID)
        
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