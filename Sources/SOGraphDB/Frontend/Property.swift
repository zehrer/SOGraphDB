//
//  File.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public enum PropertyType {
    case undefined
    case boolean
    case integer
    //case double
    case string
    //kNSNumberType,
    //     kLongType,
    // kUnsignedLongType,
    //    kNSDataType,
    //    kSOIDType,
    //    kNSDateType,
    //    kNSPointType,
    //    kNSRangeType,
    // kNSDecimalType,
    // kNSUUIDType
    //    kNSURLType  // may not work
}

public struct Property {
    
    public var uid: UID!
    public var dirty: Bool = true
    
    public var type = PropertyType.undefined 
    
    public var boolValue : Bool? = nil {
        didSet {
            type = PropertyType.boolean
        }
    }
    public var intValue : Int? = nil {
        didSet {
            type = PropertyType.integer
        }
    }
    public var stringValue : String? = nil {
        didSet {
            type = PropertyType.string
        }
    }
    
    
    //public var owner : PropertyAccess! = nil
    //public var keyNode : Node
    public var keyNodeID : UID
    
    //var isNodeSource: Bool = false;         // 3  <- yes = property of a node / no = property of a relationship
    
    //var sourceID: UID = 0  // the ID of the related node or relationship

    public init(keyNodeID: UID) {
        //self.keyNode = key
        self.keyNodeID = keyNodeID // key.uid
    }
    
    /**
    public init( related : PropertyAccess) {
        
        sourceID = related.uid!
        
        // default is false
        if related is Node {
            isNodeSource = true
        }
    }
    */

}
