//
//  PropertyGraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class PropertyElement : GraphElement { // PropertyAccess
    
    public var uid: UID!
    
    var properties = [UID : Property]()
    
    public func onAllProperties(_ closure: (Property) -> Void) {
        for property in properties.values {
            closure(property)
        }
    }
    
    public subscript(keyNode: Node) -> Property {
         get {
            //assert(context != nil, "No GraphContext available")
            if let result = propertyByKey(keyNode) {
                return result
            } else {
                return createPropertyFor(keyNode)
            }
        }
    }
    
    // Create a new property and add it to this element
    // This methode update
    //   - (optional) the lastProperty -> the property was appended directly
    //   - (optional) the element  -> the property was appended
    // PreConditions: Element is in a context
    func createPropertyFor(_ keyNode: Node) -> Property {
        //assert(context != nil, "No GraphContext available")
        //assert(keyNode.uid != nil, "KeyNode without a uid")
        
 
        //var property = Property(related: self)
        let property = Property(keyNodeID: keyNode.uid)
        //property.related =
        //property.keyNodeID = keyNode.uid!
        
        //context.registerProperty(&property)
        //context.updateProperty(property)
        //append(&property)
        
        properties[keyNode.uid] = property
        
        return property
    }
    
    public func propertyByKey(_ keyNode: Node) -> Property? {
        
        if properties.isEmpty {
            return nil
        }
        
        let result : Property? = properties[keyNode.uid!]
        
        return result
    }
}
