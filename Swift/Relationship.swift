//
//  Relationship.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public struct Relationship : ValueStoreElement {
    
    public var uid: UID? = nil
    public var dirty = true
    public weak var context : GraphContext? = nil
    
    var relationshipTypeNodeID: UID = 0;
    var nextPropertyID: UID  = 0;
    
    var startNodeID: UID = 0;
    var startNodePreviousRelationID: UID = 0;
    var startNodeNextRelationID: UID = 0;
    
    var endNodeID: UID = 0;
    var endNodePreviousRelationID: UID = 0;
    var endNodeNextRelationID: UID = 0;
    
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
}