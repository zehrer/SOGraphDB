//
//  GraphContext.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

// NEW

import Foundation

let cNodeStoreFileName         = "nodestore.db"
let cRelationshipStoreFileName = "relation.db"
let cPropertyStoreFileName     = "property.db"
let cStringFileFolder          = "str"
//let cStringStoreFileName       = "stringstore.db"

public protocol Context {
    
    weak var context : GraphContext! { get set }
    
    var dirty: Bool {get set}
}

open class GraphContext {
    
    // Singletons
    //static let sharedInstance 
    
    open let url: URL
    open let docURL: URL
    //public var error: NSError?  // readonly?
    var temporary = false  // // delete data wrapper after closing the context
    
    var nodeStore: ValueStore<Node>!
    var relationshipStore: ValueStore<Relationship>!
    var propertyStore: ValueStore<Property>!
    //var stringStore: StringStore!
    
    //MARK: - 
    
    public init(url: URL) {
        self.url = url
        self.docURL = url.appendingPathComponent(cStringFileFolder)
        setupFileStores()
    }

    deinit {
        
        // should close all files
        nodeStore = nil;
        relationshipStore = nil;
        propertyStore = nil;
        //stringStore = nil;
        
        if temporary {
            url.deleteFile()
            NSLog("GraphContext file wrapper was deleted because temporary was enabled")
        }
    }
    
    // ---- Cache ----
    
    /**
    public func cacheLimit(limit: Int) {
        nodeStore.cache.countLimit = limit
        relationshipStore.cache.countLimit = limit
        //propertyStore.cache.countLimit = limit
    }
    
    public func cacheDelegate(cacheDelegate : NSCacheDelegate?) {
        nodeStore.cache.delegate = cacheDelegate
        relationshipStore.cache.delegate = cacheDelegate
    }
    */
    
    // ---- SetUp ----

    func setupFileStores() {
        
        //var error : NSError?
        
        // TODO: ERROR Handling
        let directoryFileWrapper: FileWrapper? = try! FileWrapper(url: url, options:FileWrapper.ReadingOptions.immediate)
        
        if directoryFileWrapper == nil {
            // file wrapper does not exist yet
            let fileManager = FileManager.default
            
            //error = nil;  // remove file not found error
            
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
            try! fileManager.createDirectory(at: docURL, withIntermediateDirectories: true, attributes: nil)
            
        } else {
            if !directoryFileWrapper!.isDirectory {
                // if filewrapper not a folder -> ERROR
                // TODO : set error
                //self.error = NSError(domain: "graphdb.sobj.com", code: 1, userInfo: nil)
                return
            }
        }
        
        let nodeStoreURL = url.appendingPathComponent(cNodeStoreFileName)
        let relationshipStoreURL = url.appendingPathComponent(cRelationshipStoreFileName)
        let propertyStoreURL = url.appendingPathComponent(cPropertyStoreFileName)
        
        do {
            try nodeStore = ValueStore<Node>(url: nodeStoreURL)
            try relationshipStore = ValueStore<Relationship>(url:relationshipStoreURL)
            try propertyStore = ValueStore<Property>(url: propertyStoreURL)
            
        } catch {
            // TODO error handling
        }
        
        
        //nodeStore = ObjectDataStore<Node>(url: nodeStoreURL)
        //nodeStore.cache.name = "nodeStore"  // TODO: automate
        
        
        //relationshipStore = ObjectDataStore<Relationship>(url:relationshipStoreURL)
        //relationshipStore.setupStore(SORelationship())
        //nodeStore.cache.name = "relationshipStore"
        
        
        //propertyStore = ObjectDataStore<Property>(url: propertyStoreURL)
        //propertyStore.setupStore(SOProperty())
        //propertyStore.cache.name = "propertyStore"
        
        //let stringStoreURL = url.URLByAppendingPathComponent(cStringStoreFileName)
        //stringStore = StringStore(url:stringStoreURL)
    }
    
    /**
    
    func setCacheLimit(newValue: Int) {
        nodeStore.cache.countLimit = newValue
        relationshipStore.cache.countLimit = newValue
        propertyStore.cache.countLimit = newValue
    }
    
    func setCacheDelegate(newValue: NSCacheDelegate) {
        nodeStore.cache.delegate = newValue;
        relationshipStore.cache.delegate = newValue;
        propertyStore.cache.delegate = newValue;
    }
    */
    
    // MARK: CRUD Node
    
    // No add method, node has no parameter they need just created
    open func createNode() -> Node {
        
        var result = nodeStore.createValue()
        
        result.context = self
        
        return result;
    }
    
    open func readNode(_ aID: UID) -> Node? {
        
        //NSParameterAssert(aID != 0);
        
        var result : Node? = nodeStore.readValue(aID)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    open func update(_ aNode: inout Node) {
        if aNode.dirty {
            nodeStore.updateValue(aNode)
            
            aNode.dirty = false
        }
    }

    open func delete(_ aNode: inout Node) {
        nodeStore.delete(aNode)
        aNode.context = nil;
    }

    // MARK: CRUD Relationship

    func registerRelationship(_ aRelationship: inout Relationship) {
        aRelationship.uid = relationshipStore.registerValue()
        aRelationship.context = self
    }
    
    func update(_ aRelationship: inout Relationship) {
        if aRelationship.dirty {
            relationshipStore.updateValue(aRelationship)
            
            aRelationship.dirty = false
        }
    }

    open func readRelationship(_ uid:UID) -> Relationship? {
        
        var result = relationshipStore.readValue(uid)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    func delete(_ aRelationship: inout Relationship) {
        
        relationshipStore.delete(aRelationship)
        
        aRelationship.context = nil
        aRelationship.uid = 0
    }

    // MARK:  CRUD Property

    // created and UID without the data is written in the store
    
    func registerProperty(_ value : inout Property) {
        value.uid = propertyStore.registerValue()
        value.context = self
    }

    /**
    func addProperty(aObj: Property) {
        
        propertyStore.addObject(aObj)
        aObj.context = self
    }
*/
    
    open func readProperty(_ aID:UID) -> Property? {
        var result = propertyStore.readValue(aID)
        
        if result != nil {
            result!.context = self
        }
        
        return result;
    }
    
    func update(_ aProperty: inout Property) {
        if aProperty.dirty {
            propertyStore.updateValue(aProperty)
            
            aProperty.dirty = false
        }
    }

    func delete(_ aProperty: inout Property) {
        propertyStore.delete(aProperty)
        aProperty.context = nil
        aProperty.uid = 0
    }
    
    //MARK: CR(U)D Strings / NO UPDATE
    
    /**
    func addString(text: String) -> UID {
        let num =  stringStore[text]
        
        // TODO
        return num;
    }
    
    
    func readStringAtIndex(index: UID) -> String? {
        return stringStore[index]
    }

    func deleteStringAtIndex(index: UID) {
        stringStore[index] = nil
    }
    */
    
    func stringURLNameFor(_ property : Property) -> URL {
        
        return docURL.appendingPathComponent("p\(property.uid!).txt")
    }
    
    // used
    func readStringFor(_ property : Property) -> String? {
        // TODO ERROR HANDLIGN
        return try! String(contentsOf: stringURLNameFor(property), encoding: String.Encoding.utf8)
    }
    
    // not used
    func writeStringData(_ stringData: Data, ofProperty property : Property) {
        try? stringData.write(to: stringURLNameFor(property), options: [.atomic])
    }
    
    // used
    func writeString(_ string: String, ofProperty property : Property) {
        // TODO ERROR HANDLIGN
        try! string.write(to: stringURLNameFor(property), atomically: true, encoding: String.Encoding.utf8)
    }

}


/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

