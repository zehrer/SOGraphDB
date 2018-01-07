//
//  PropertyAccess.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol PropertyAccess : Identiy { // , Context , CRUD
    
    // The uid if the keyNode is the reference
    var propertiesDictionary:[UID : Property] { get}
    
    subscript(keyNode: Node) -> Property { mutating get}
    
    func propertyByKey(_ keyNode:Node) -> Property?
    
    //func containsProperty(keyNode:Node) -> Bool
    
}

extension PropertyAccess {
    
    public subscript(keyNode: Node) -> Property {
        mutating get {
            //assert(context != nil, "No GraphContext available")
            let result = propertyByKey(keyNode)
            if let result = result {
                return result
            } else {
                return createPropertyFor(keyNode)
            }
        }
    }
    

    
    public func propertyByKey(_ keyNode: Node) -> Property? {
        
        if propertiesDictionary.isEmpty {
            return nil
        }
        
        let result : Property? = propertiesDictionary[keyNode.uid!]
        
        return result
    }
}
