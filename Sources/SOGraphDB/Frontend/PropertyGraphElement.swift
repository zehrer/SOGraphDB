//
//  PropertyGraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class PropertyGraphElement : GraphElement, PropertyAccess {

    public var uid: UID!
    
    public var propertiesDictionary = [UID : Property]()
    
    public subscript(keyNode: Node) -> Property {
         get {
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
    //   - (optional) the lastProperty -> the property was appended directly
    //   - (optional) the element  -> the property was appended
    // PreConditions: Element is in a context
    func createPropertyFor(_ keyNode: Node) -> Property {
        //assert(context != nil, "No GraphContext available")
        //assert(keyNode.uid != nil, "KeyNode without a uid")
        
 
        //var property = Property(related: self)
        let property = Property(key: keyNode)
        //property.related =
        //property.keyNodeID = keyNode.uid!
        
        //context.registerProperty(&property)
        //context.updateProperty(property)
        //append(&property)
        
        propertiesDictionary[keyNode.uid] = property
        
        return property
    }
}
