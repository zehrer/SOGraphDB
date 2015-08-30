//
//  Node.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 02.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

extension Node : Identiy, PropertyAccess {}


// Equatable interface for Node
public func ==(lhs: Node, rhs: Node) -> Bool {
    
    if (lhs.uid != nil &&  rhs.uid != nil) {
    
        if lhs.uid! == rhs.uid! {
           return true
        }
    }
    
    return false
}

public struct Node : ValueStoreElement , Context , Hashable {
    
    public weak var context : GraphContext! = nil
    
    public var uid: UID? = nil
    public var dirty = true
    
    public var nextPropertyID: UID = 0
    
    var nextOutRelationshipID: UID  = 0
    var nextInRelationshipID: UID  = 0
    
    
    public static func generateSizeTestInstance() -> Node {
        var result = Node()
        result.nextPropertyID = Int.max
        result.nextOutRelationshipID = Int.max
        result.nextInRelationshipID = Int.max
        
        return result
    }

    public init() {}
    
    public init (uid aID : UID) {
        uid = aID
    }
    
    public init(coder decoder: Decode) {
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
    
    // MARK: CRUD
    
    public mutating func delete() {
        context.delete(&self)
    }
    
    public mutating func update() {
        context.update(&self)
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        get {
            if uid != nil {
                return uid!.hashValue
            }
            return 0
        }
    }
    
    
}