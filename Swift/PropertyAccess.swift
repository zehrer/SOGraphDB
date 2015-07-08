//
//  PropertyAccess.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 05.07.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

/**
// Exampled how to use

var a = Node() // <- auto default context (not implemented yet !!!)
var b = Node() // <- auto default context
var keyNode = Node()

a[keyNode].value = 1
b[keyNode].value = "Test"

var result = a[keyNode].value


a[keyNode].valueInt = 1
b[keyNode].valueString = "Test"

*/


public protocol PropertyAccess : Context {
    
    var nextPropertyID: UID {get set}  // internal link to the property
    
    var propertiesArray: [Property] {get}
    var propertiesDictionary:[UID: Property] {get}
    
    subscript(keyNode: Node) -> Property {get set}
    
    func propertyForKey(keyNode:Node) -> Property?
    
    func containsProperty(keyNode:Node) -> Bool
    
}

extension PropertyAccess {
    
    public subscript(keyNode: Node) -> Property {
        get {
            //assert(context != nil, "No GraphContext available")
            var property = propertyForKey(keyNode)
            
            if (property == nil) {
                //property = createPropertyForKeyNode(keyNode)
            }
            
            return property!
            
        }
    }
    
    public func propertyForKey(keyNode:Node) -> Property? {
        
        //assert(keyNode.uid != nil, "KeyNode without a uid")
        
        return propertiesDictionary[keyNode.uid!]
    }
    
    
    // Generic read methode
    func readProperty(handler : (property : Property) -> Void) {
        
        var property:Property? = nil
        var nextPropertyID = self.nextPropertyID
        
        while (nextPropertyID > 0) {
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                
                handler(property: property!)
                
                nextPropertyID = property!.nextPropertyID
            } else {
                // TODO: REPORT ERROR
            }
        }
    }
    
    func readPropertyByKey(keyNode : Node) -> Property? {
        
        var property:Property? = nil
        var nextPropertyID = self.nextPropertyID
        
        while (nextPropertyID > 0) {
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                
                if property!.keyNodeID == keyNode.uid {
                    return property
                }
                
                nextPropertyID = property!.nextPropertyID
            } else {
                // ERROR: inconsistent database
            }
        }
        
        return nil
    }
    

    
    func readPropertyArray() -> [Property] {
        
        var propertiesArray: [Property] =  [Property]()
        //var propertiesDictionary:[UID: Property] = [UID: Property]()

        // read data
        var property:Property? = nil
        var nextPropertyID = self.nextPropertyID
        
        while (nextPropertyID > 0) {
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                // addToPropertyCollections(property!)
                propertiesArray.append(property!)
                //propertiesDictionary[property!.keyNodeID] = property
                
                nextPropertyID = property!.nextPropertyID
            } else {
                // TODO: REPORT ERROR
            }
        }
        
        return propertiesArray
    }
    
    func readPropertyDictionary() -> [UID: Property] {
        
        //var propertiesArray: [Property] =  [Property]()
        var propertiesDictionary:[UID: Property] = [UID: Property]()
        
        // read data
        var property:Property? = nil
        var nextPropertyID = self.nextPropertyID
        
        while (nextPropertyID > 0) {
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                // addToPropertyCollections(property!)
                //propertiesArray.append(property!)
                propertiesDictionary[property!.keyNodeID] = property
                
                nextPropertyID = property!.nextPropertyID
            } else {
                // TODO: REPORT ERROR
            }
        }
        
        return propertiesDictionary
    }
    
    

}