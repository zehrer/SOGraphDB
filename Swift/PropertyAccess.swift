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

public protocol CRUD {
    
    // create and read missing :)
    
    mutating func update()
    mutating func delete()
    
}


public protocol PropertyAccess : Identiy, Context, CRUD {
    
    var nextPropertyID: UID {get set}  // internal link to the property
    
    //var propertiesArray: [Property] {get}  //
    //var propertiesDictionary:[UID: Property] {get}
    
    subscript(keyNode: Node) -> Property { mutating get}
    
    func propertyByKey(keyNode:Node) -> Property?
    
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
    mutating func createPropertyFor(keyNode : Node) -> Property {
        assert(context != nil, "No GraphContext available")
        assert(keyNode.uid != nil, "KeyNode without a uid")
        
        var property = Property(related: self)
        property.keyNodeID = keyNode.uid!
        
        context.registerProperty(&property)
        //context.updateProperty(property)
        append(&property)
        
        return property
    }
    
    // This methode will update
    // - in any case the property itself
    // - this element in case of first property
    // - the last property in the chain in case it is not the first one
    mutating func append(inout property : Property) {
        
        if nextPropertyID == 0 {
            // first element
            
            // add property to the element  (e.g. Node -> Property)
            nextPropertyID = property.uid!
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
            
        } else {
            // appent element at the end of the chain
            
            let propertiesArray = readPropertyArray()
            var lastProperty = propertiesArray.last
            
            if lastProperty != nil {
                // it seems this element has already one or more properties
                // add property to the last one
                property.previousPropertyID = lastProperty!.uid!;
                lastProperty!.nextPropertyID = property.uid!;
                
                // CONTEXT WRITE
                // updated of the LAST relationship is only required if
                // the is was extended
                context.update(&lastProperty!)
            } else {
                // ERROR: lastProperty is nil even nextPropertyID is not set to zero
                assertionFailure("ERROR: Database inconsistent")
            }
            
        }
        
        // CONTEXT WRTIE
        context.update(&property)
    }
    
    
    // Generic read methode
    // The handler is called by all properties of the chain
    // Return: true if the while loop can be stopped
    func readProperty(handler : (property : Property) -> Bool) {
        
        var property:Property? = nil
        var nextPropertyID = self.nextPropertyID
        
        while (nextPropertyID > 0) {
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                
                let stop = handler(property: property!)
                
                if stop {
                    break
                }
                
                nextPropertyID = property!.nextPropertyID
            } else {
                // ERROR: nextPropertyID is not zero but readProperty read nil
                assertionFailure("ERROR: Database inconsistent")
            }
        }
    }
    
    public func propertyByKey(keyNode : Node) -> Property? {
        
        var result : Property? = nil
        
        readProperty({ property in
            
            if property.keyNodeID == keyNode.uid {
                result = property
                return true
            }
            
            return false
            
        })
        
        return result
    }
    
    func readPropertyArray() -> [Property] {
        
        var propertiesArray: [Property] =  [Property]()
        
        readProperty({ property in
            
            propertiesArray.append(property)
            
            return false
        })
        
        return propertiesArray
    }
    
    func readPropertyDictionary() -> [UID: Property] {
        
         var propertiesDictionary:[UID: Property] = [UID: Property]()
        
        readProperty({ property in
            
            propertiesDictionary[property.keyNodeID] = property
            
            return false
            
        })
        
        return propertiesDictionary
    }
    
    mutating func deleteProperty(inout property:Property) {
        
        assert(context != nil, "No GraphContext available")
        
        var previousProperty:Property? = nil
        var nextProperty:Property? = nil
        
        let nextPropertyID:UID = property.nextPropertyID
        let previousPropertyID = property.previousPropertyID
        
        if (nextPropertyID > 0) {
            nextProperty = context.readProperty(nextPropertyID)
            
            if (nextProperty != nil) {
                nextProperty!.previousPropertyID = previousPropertyID
                
                // CONTEXT WRITE
                context.update(&nextProperty!)
            } else {
                // ERROR: nextPropertyID is not zero but readProperty return nil
                assertionFailure("ERROR: Database inconsistent")
            }
        }
        
        if (previousPropertyID > 0) {
            previousProperty = context!.readProperty(previousPropertyID)
            
            if (nextProperty != nil) {
                previousProperty!.nextPropertyID = nextPropertyID
                
                // CONTEXT WRITE
                context.update(&previousProperty!)
            } else {
                // ERROR: previousProperty is not zero but readProperty return nil
                assertionFailure("ERROR: Database inconsistent")
            }
            
        } else {
            // seems this is the first property in the chain
           self.nextPropertyID = nextPropertyID
            
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }

        // last step delete the property itself
        property.delete()
    }

}