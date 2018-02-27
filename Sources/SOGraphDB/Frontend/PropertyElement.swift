//
//  PropertyGraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class PropertyElement : Hashable { // PropertyAccess, GraphElement
    
    public var uid: UID!
    public var graphStore: SOGraphDBStore!
    public var dirty: Bool = true
    
    lazy var properties = [UID : Property]()
    
    public init() {
    }
    
    public init(uid: UID) {
        self.uid = uid
    }
    
    
    // MARK: - Hashable
    
    public var hashValue: Int {
        get{
            return uid.hashValue
        }
    }
    
    public static func == (lhs: PropertyElement, rhs: PropertyElement) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    // MARK: -
    
    public func onAllProperties(_ closure: (Property) -> Void) {
        for property in properties.values {
            closure(property)
        }
    }
    
    public subscript(keyNode: Node) -> Property {
         get {
            //assert(context != nil, "No GraphContext available")
            if let result = properties[keyNode.uid] {
                return result
            } else {
                return createPropertyFor(keyNode)
            }
        }
    }
    
    public subscript(keyNodeID : UID) -> Property {
        get {
            if let result = properties[keyNodeID] {
                return result
            } else {
                return createPropertyForKeyNode(uid: keyNodeID)
            }
        }
        set(newValue) {
            properties[keyNodeID] = newValue
        }
    }
    
    func createPropertyForKeyNode(uid: UID) -> Property {
        let property = Property(keyNodeID: uid)
        properties[uid] = property
        return property
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
    
    /**
    public func propertyByKey(_ keyNode: Node) -> Property? {
        
        if properties.isEmpty {
            return nil
        }
        
        return properties[keyNode.uid!]
    }
    */
 
    public func propertyByKeyNodeID(uid: UID) -> Property? {
        return properties[uid]
    }
    
    // MARK: - Type System
    
    // subclass have to override
    public func setType(of type:Node) {
        fatalError("Must Override")
    }
    


}
