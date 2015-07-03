//
//  Node.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation


public struct Node : ValueStoreElement {
    
    public var uid: UID? = nil
    public var dirty = true
    
    var nextPropertyID: UID = 0 {
        didSet {
            if nextPropertyID != oldValue {
                dirty = true
            }
        }
    }
    
    var nextOutRelationshipID: UID  = 0 {
        didSet {
            if nextOutRelationshipID != oldValue {
                dirty = true
            }
        }
    }

    var nextInRelationshipID: UID  = 0 {
        didSet {
            if nextInRelationshipID != oldValue {
                dirty = true
            }
        }
    }
    
    public static func generateSizeTestInstance() -> Node {
        var result = Node()
        result.nextPropertyID = Int.max
        result.nextOutRelationshipID = Int.max
        result.nextInRelationshipID = Int.max
        
        return result
    }

    public init() {}
    
    public init(coder decoder: Decoder) {
        nextPropertyID = decoder.decode()
        nextOutRelationshipID  = decoder.decode()
        nextInRelationshipID = decoder.decode()
        
        dirty = false
    }
    
    public func encodeWithCoder(encoder : Encode) {
        encoder.encode(nextPropertyID)
        encoder.encode(nextOutRelationshipID)
        encoder.encode(nextInRelationshipID)
    }
    
    
    
}