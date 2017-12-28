//
//  PropertyAccess.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol PropertyAccess : Identiy { // , Context , CRUD
    
    //var nextPropertyID: UID {get set}  // internal link to the property
    
    //var propertiesArray: [Property] {get}  //
    
    //
    var propertiesDictionary:[UID : Property] {get}
    
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
    
    // Create a new property and add it to this element
    // This methode update
    //   - the new property (twice, 1. create 2. update)
    //   - (optional) the lastProperty -> the property was appended directly
    //   - (optional) the element  -> the property was appended
    // PreConditions: Element is in a context
    mutating func createPropertyFor(_ keyNode : Node) -> Property {
        //assert(context != nil, "No GraphContext available")
        assert(keyNode.uid != nil, "KeyNode without a uid")
        
        var property = Property(related: self)
        property.keyNodeID = keyNode.uid!
        
        //context.registerProperty(&property)
        //context.updateProperty(property)
        //append(&property)
        
        return property
    }
    
    public func propertyByKey(_ keyNode : Node) -> Property? {
        
        if propertiesDictionary.isEmpty {
            // TODO readProperty
        }
        
        let result : Property? = propertiesDictionary[keyNode.uid!]
        
        return result
    }
}
