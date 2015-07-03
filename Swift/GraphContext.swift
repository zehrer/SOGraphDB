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
let cStringFileFolder          = "doc"
let cStringStoreFileName       = "stringstore.db"

public class GraphContext {
    
    public let url: NSURL
    public let docURL: NSURL
    //public var error: NSError?  // readonly?
    var temporary = false  // // delete data wrapper after closing the context
    
    var nodeStore: ValueStore<Node>!
    var relationshipStore: ValueStore<Relationship>!
    var propertyStore: ValueStore<Property>!
    //var stringStore: StringStore!
    
    //#pragma mark -
    
    public init(url: NSURL) {
        self.url = url
        self.docURL = url.URLByAppendingPathComponent(cStringFileFolder)
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
        let directoryFileWrapper: NSFileWrapper? = try! NSFileWrapper(URL: url, options:NSFileWrapperReadingOptions.Immediate)
        
        if directoryFileWrapper == nil {
            // file wrapper does not exist yet
            let fileManager = NSFileManager.defaultManager()
            
            //error = nil;  // remove file not found error
            
            try! fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            
            try! fileManager.createDirectoryAtURL(docURL, withIntermediateDirectories: true, attributes: nil)
            
        } else {
            if !directoryFileWrapper!.directory {
                // if filewrapper not a folder -> ERROR
                // TODO : set error
                //self.error = NSError(domain: "graphdb.sobj.com", code: 1, userInfo: nil)
                return
            }
        }
        
        let nodeStoreURL = url.URLByAppendingPathComponent(cNodeStoreFileName)
        let relationshipStoreURL = url.URLByAppendingPathComponent(cRelationshipStoreFileName)
        let propertyStoreURL = url.URLByAppendingPathComponent(cPropertyStoreFileName)
        
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
    public func createNode() -> Node {
        
        var result = nodeStore.createValue()
        
        result.context = self
        
        return result;
    }
    
    public func readNode(aID: UID) -> Node? {
        
        //NSParameterAssert(aID != 0);
        
        var result : Node? = nodeStore.readValue(aID)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    public func updateNode(aNode: Node) {
        nodeStore.updateValue(aNode)
    }

    public func deleteNode(inout aNode: Node) {
        nodeStore.delete(aNode)
        
        aNode.context = nil;
    }

    // MARK: CRUD Relationship
    
    /**
    func registerRelationship(aRelationship: Relationship) {
        relationshipStore.registerObject(aRelationship)
        
        aRelationship.context = self
    }
    */
    
    func updateRelationship(aRelationship: Relationship) {
        relationshipStore.updateValue(aRelationship)
    }

    public func readRelationship(uid:UID) -> Relationship? {
        
        var result = relationshipStore.readValue(uid)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    func deleteRelationship(inout aRelationship: Relationship) {
        relationshipStore.delete(aRelationship)
        
        aRelationship.context = nil;
    }

    // MARK:  CRUD Property
    
    
    // created and UID without the data is written in the store
    /**
    func registerProperty(aObj: Property) {
        
        propertyStore.registerObject(aObj)
        aObj.context = self
    }

    
    func addProperty(aObj: Property) {
        
        propertyStore.addObject(aObj)
        aObj.context = self
    }
*/
    
    public func readProperty(aID:UID) -> Property? {
        var result = propertyStore.readValue(aID)
        
        if result != nil {
            result!.context = self
        }
        
        return result;
    }
    
    func updateProperty(aProperty: Property) {
        propertyStore.updateValue(aProperty)
    }

    func deleteProperty(inout aProperty: Property) {
        propertyStore.delete(aProperty)
        
        aProperty.context = nil;
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
    
    func stringURLNameFor(property : Property) -> NSURL {
        
        return docURL.URLByAppendingPathComponent("p\(property.uid!).txt")
    }
    
    // used
    func readStringFor(property : Property) -> String? {
        // TODO ERROR HANDLIGN
        return try! String(contentsOfURL: stringURLNameFor(property), encoding: NSUTF8StringEncoding)
    }
    
    // not used
    func writeStringData(stringData: NSData, ofProperty property : Property) {
        stringData.writeToURL(stringURLNameFor(property), atomically: true)
    }
    
    // used
    func writeString(string: String, ofProperty property : Property) {
        // TODO ERROR HANDLIGN
        try! string.writeToURL(stringURLNameFor(property), atomically: true, encoding: NSUTF8StringEncoding)
    }

}


/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

