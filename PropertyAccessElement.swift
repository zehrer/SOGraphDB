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
            
            property = context.readProperty(nextPropertyID)
            
            if (property != nil) {
                addToPropertyCollections(property!)
                nextPropertyID = property!.nextPropertyID
            } else {
                // TODO: REPORT ERROR
            }
        }
    }
    
    func addToPropertyCollections(property:Property) {
        _propertiesArray!.append(property)
        _propertiesDictionary![property.keyNodeID] = property
    }

    
    func deleteValueForKey(keyNode:Node) {
        if (context != nil) {
            var property = propertyForKey(keyNode)
            if (property != nil) {
                //var data = property.data
                deleteProperty(property!)
                
                // return data
            }
        }
        
        //return nil
    }
    
    //MARK: PropertyAccess Support
    
    func raiseError() {
        //#warning writing exception key
        //[NSException raise:NSInvalidArchiveOperationException format:@"Property for key not found"];
    }
    
    func propertyForKey(keyNode:Node) -> Property? {
        
        return propertiesDictionary[keyNode.uid]
    }
    
    func deleteProperty(property:Property) {
        
    }

    func createPropertyForKeyNode(keyNode:Node) -> Property {
        assert(context != nil, "No GraphContext available")
        
        var property = Property(graphElement: self, keyNode: keyNode)
        
        context.registerProperty(property)
        addProperty (property)
        
        return property
    }

    // 
    func addProperty(property:Property) {
        //assert(context != nil, "No GraphContext available")
        
        var lastProperty = propertiesArray.last
        
        if (lastProperty != nil) {
            // it seems this element has already one or more properties
            // add property to the last one
            property.previousPropertyID = lastProperty!.uid;
            lastProperty!.nextPropertyID = property.uid;
            
            // CONTEXT WRITE
            // updated of the LAST relationship is only required if
            // the is was extended
           context.updateProperty(lastProperty!)
            
        } else {
            // It seems this is the frist property
            
            // add property to the element  (e.g. Node -> Property)
            self.propertyID = property.uid
            
            // CONTEXT WRITE
            // update of self is only required if the id was set
            self.update()
        }
        
        // CONTEXT WRTIE
        context.updateProperty(property)
        
        // add property to internal array
        addToPropertyCollections(property)
    }
    

    
    // MARK: PropertyAccess Protocoll (TODO)
    
}