//
//  PropertyAccessElement.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


public class PropertyAccessElement : GraphElement {
    
    // MARK: Init
    
    // is required in the coding if the subclassess
    required public init() {
    }
    
    // MARK: Subclass
    
    // subclasses have to override this
    var propertyID : UID {
        get {
            return 0
        }
        set {
            // override
        }
    }
    
    // override
    func update() {
        
    }
    
    
    // MARK: General
    
    var _propertiesArray:[Property]? = nil
    var _propertiesDictionary:[UID: Property]? = nil // The key is the UID of the keyNode

    public var propertiesArray: [Property] {
        get {
            assert(context != nil, "No GraphContext available")
            if (_propertiesArray == nil) {
                initPropertyData()
                readPropertyData()
            }
            return _propertiesArray!
        }
    }
    
    public var propertiesDictionary:[UID: Property] {
        get {
            assert(context != nil, "No GraphContext available")
            if (_propertiesDictionary == nil)  {
                initPropertyData()
                readPropertyData()
            }
            return _propertiesDictionary!
        }
    }
    
    func initPropertyData() {
        _propertiesArray = [Property]()
        _propertiesDictionary = Dictionary<UID, Property>()
    }

    func readPropertyData() {
        
        // read data
        var property:Property? = nil;
        var nextPropertyID = propertyID;
        
        while (nextPropertyID > 0) {
            
            property = context!.readProperty(nextPropertyID)
            
            if (property != nil) {
                addToPropertyCollections(property!)
                nextPropertyID = property!.nextPropertyID
            } else {
                // TODO: REPORT ERROR
            }
        }
    }
    
    func addToPropertyCollections(property:Property) {
        //assert(_propertiesDictionary != nil, "PropertyData was not loaded or added")
        //assert(_propertiesArray != nil, "PropertyData was not loaded or added")
        
        _propertiesArray!.append(property)
        _propertiesDictionary![property.keyNodeID] = property
    }
    
    func removedFromPropertyCollections(property:Property) {
        //assert(_propertiesDictionary != nil, "PropertyData was not loaded or added")
        //assert(_propertiesArray != nil, "PropertyData was not loaded or added")
            
        _propertiesDictionary!.removeValueForKey(property.keyNodeID)
        
        //let index = find(_propertiesArray!, property) // init propertiesArray in worst case
        let index = _propertiesArray!.indexOf(property)
        if let index = index {
             _propertiesArray!.removeAtIndex(index)
        }
    }
    
    
    public func deletePropertyForKey(keyNode:Node) {
        if (context != nil) {
            let property = propertyForKey(keyNode)
            if (property != nil) {
                //var data = property.data
                deleteProperty(property!)
                
                // return data
            }
        }
        
        //return nil
    }
    
    //MARK: PropertyAccess Support
    
    public func propertyForKey(keyNode:Node) -> Property? {
        
        assert(keyNode.uid != nil, "KeyNode without a uid")
        
        return propertiesDictionary[keyNode.uid!]
    }
    
    public func containsProperty(keyNode:Node) -> Bool {
        let property = propertyForKey(keyNode)
        if property == nil {
            return false
        }
    
        return true
    }
    
    // PreConditions: Element is in a context
    func ensurePropertyforKey(keyNode:Node) -> Property {
        var property = propertyForKey(keyNode)
    
        if (property == nil) {
            property = createPropertyForKeyNode(keyNode)
        }
    
        return property!
    }
    
    // Create a new property and add it to this element
    // This methode update
    //   - the new property (twice, 1. create 2. update)
    //   - (optional) the lastProperty -> the property was appended directly
    //   - (optional) the element  -> the property was appended
    // PreConditions: Element is in a context
    func createPropertyForKeyNode(keyNode:Node) -> Property {
        assert(context != nil, "No GraphContext available")
        
        let property = Property(graphElement: self, keyNode: keyNode)
        
        context!.registerProperty(property)
        addProperty (property)
        
        return property
    }

    func addProperty( property : Property) {
        //assert(context != nil, "No GraphContext available")
        assert(property.uid != nil, "KeyNode without a uid")
        
        let lastProperty = propertiesArray.last
        
        if (lastProperty != nil) {
            // it seems this element has already one or more properties
            // add property to the last one
            property.previousPropertyID = lastProperty!.uid!;
            lastProperty!.nextPropertyID = property.uid!;
            
            // CONTEXT WRITE
            // updated of the LAST relationship is only required if
            // the is was extended
           context!.updateProperty(lastProperty!)
            
        } else {
            // It seems this is the frist property
            
            // add property to the element  (e.g. Node -> Property)
            self.propertyID = property.uid!
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        // CONTEXT WRTIE
        context!.updateProperty(property)
        
        // add property to internal array
        addToPropertyCollections(property)
    }
    
    func deleteProperty(property:Property) {
        
        assert(context != nil, "No GraphContext available")
        
        var previousProperty:Property? = nil
        var nextProperty:Property? = nil
        
        let nextPropertyID:UID = property.nextPropertyID
        let previousPropertyID = property.previousPropertyID
        
        if (nextPropertyID > 0) {
            nextProperty = context!.readProperty(nextPropertyID)
            
            if (nextProperty != nil) {
              nextProperty!.previousPropertyID = previousPropertyID
                
              // CONTEXT WRITE
              context!.updateProperty(nextProperty!)
            } else {
                // TODO: ERROR
            }
        }
        
        if (previousPropertyID > 0) {
            previousProperty = context!.readProperty(previousPropertyID)
            
            if (nextProperty != nil) {
                previousProperty!.nextPropertyID = nextPropertyID
                
                // CONTEXT WRITE
                context!.updateProperty(previousProperty!)
            } else {
                // TODO: ERROR
            }
            
        } else {
            // seems this is the first property in the chain
            self.propertyID = nextPropertyID
            
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        // update property to internal array and maps
        removedFromPropertyCollections(property)
        
        // last step delete the property itself
        property.delete()
    }
    
    func raiseError() {
        //#warning writing exception key
        //[NSException raise:NSInvalidArchiveOperationException format:@"Property for key not found"];
    }

    //MARK: PropertyAccess Protocol
    
    public subscript(keyNode: Node) -> Property {
        get {
            assert(context != nil, "No GraphContext available")
            return ensurePropertyforKey(keyNode)
        }
        /**
        
        set a nil valie would lead to an optional return value
        
        set {
            if newValue == nil {
                var property = propertyForKey(keyNode)
                
                if property != nil {
                    deleteProperty(property!)
                }
                // property == nil -> do nothing :)
            } else {
                assertionFailure("ERROR: this interface does not allow setting values")
            }
        }
*/
    }
    
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

    
    /**
    subscript(keyNode: Node) -> Double {
        get {
            var property = propertyForKey(keyNode)
            if (property != nil) {
                //return property.value
            }
            raiseError()
            return 0
        }
        set {
            assert(context != nil, "No GraphContext available")
            var property = ensurePropertyforKey(keyNode)
            
            //property.value = newValue
            
            context.updateProperty(property)
        }
    }
*/
    
}