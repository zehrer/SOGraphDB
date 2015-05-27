//
//  GraphContext.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

let cNodeStoreFileName         = "nodestore.db"
let cRelationshipStoreFileName = "relation.db"
let cPropertyStoreFileName     = "property.db"
let cStringFileFolder          = "doc"
let cStringStoreFileName       = "stringstore.db"

public class GraphContext {
    
    public let url: NSURL
    public let docURL: NSURL
    public var error: NSError?  // readonly?
    var temporary = false  // // delete data wrapper after closing the context
    
    var nodeStore: ObjectStore<Node>!
    var relationshipStore: ObjectStore<Relationship>!
    var propertyStore: ObjectStore<Property>!
    var stringStore: StringStore!
    
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
        stringStore = nil;
        
        if temporary {
            url.deleteFile()
            NSLog("GraphContext file wrapper was deleted because temporary was enabled")
        }
    }
    
    // ---- Cache ----
    
    public func cacheLimit(limit: Int) {
        nodeStore.cache.countLimit = limit
        relationshipStore.cache.countLimit = limit
        //propertyStore.cache.countLimit = limit
    }
    
    public func cacheDelegate(cacheDelegate : NSCacheDelegate?) {
        nodeStore.cache.delegate = cacheDelegate
        relationshipStore.cache.delegate = cacheDelegate
    }
    
    // ---- SetUp ----

    func setupFileStores() {
        
        var error : NSError?
        
        var directoryFileWrapper: NSFileWrapper? = NSFileWrapper(URL: url, options:.Immediate, error:&error);
        
        if directoryFileWrapper == nil {
            // file wrapper does not exist yet
            var fileManager = NSFileManager.defaultManager()
            
            error = nil;  // remove file not found error
            
            fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error:&error)
            fileManager.createDirectoryAtURL(docURL, withIntermediateDirectories: true, attributes: nil, error:&error)
            
            // TODO
            self.error = error;
        } else {
            if !directoryFileWrapper!.directory {
                // if filewrapper not a folder -> ERROR
                // TODO : set error
                self.error = NSError(domain: "graphdb.sobj.com", code: 1, userInfo: nil)
                return
            }
        }
        
        var nodeStoreURL = url.URLByAppendingPathComponent(cNodeStoreFileName)
        //nodeStore = ObjectDataStore<Node>(url: nodeStoreURL)
        nodeStore = ObjectStore<Node>(url: nodeStoreURL)
        nodeStore.cache.name = "nodeStore"  // TODO: automate
        
        var relationshipStoreURL = url.URLByAppendingPathComponent(cRelationshipStoreFileName)
        //relationshipStore = ObjectDataStore<Relationship>(url:relationshipStoreURL)
        relationshipStore = ObjectStore<Relationship>(url:relationshipStoreURL)
        //relationshipStore.setupStore(SORelationship())
        nodeStore.cache.name = "relationshipStore"
        
        var propertyStoreURL = url.URLByAppendingPathComponent(cPropertyStoreFileName)
        //propertyStore = ObjectDataStore<Property>(url: propertyStoreURL)
        propertyStore = ObjectStore<Property>(url: propertyStoreURL)
        //propertyStore.setupStore(SOProperty())
        propertyStore.cache.name = "propertyStore"
        
        var stringStoreURL = url.URLByAppendingPathComponent(cStringStoreFileName)
        stringStore = StringStore(url:stringStoreURL)
    }
    
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
    
    // MARK: CRUD Node
    
    // No add method, node has no parameter they need just created
    public func createNode() -> Node {
        
        let result = nodeStore.createObject()
        
        result.context = self
        
        return result;
    }
    
    public func readNode(aID: UID) -> Node? {
        
        //NSParameterAssert(aID != 0);
        
        var result : Node? = nodeStore.readObject(aID)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    public func updateNode(aNode: Node) {
        nodeStore.updateObject(aNode)
    }

    public func deleteNode(aNode: Node) {
        nodeStore.deleteObject(aNode)
        
        aNode.context = nil;
    }

    // MARK: CRUD Relationship
    
    func registerRelationship(aRelationship: Relationship) {
        relationshipStore.registerObject(aRelationship)
        
        aRelationship.context = self
    }
    
    func updateRelationship(aRelationship: Relationship) {
        relationshipStore.updateObject(aRelationship)
    }

    public func readRelationship(uid:UID) -> Relationship? {
        
        var result = relationshipStore.readObject(uid) ;
        
        if (result != nil) {
            result.context = self
        }
        
        return result;
    }
    
    func deleteRelationship(aRelationship: Relationship) {
        relationshipStore.deleteObject(aRelationship)
        
        aRelationship.context = nil;
    }

    // MARK:  CRUD Property
    
    
    // created and UID without the data is written in the store
    func registerProperty(aObj: Property) {
        
        propertyStore.registerObject(aObj)
        aObj.context = self
    }
    
    func addProperty(aObj: Property) {
        
        propertyStore.addObject(aObj)
        aObj.context = self
    }
    
    public func readProperty(aID:UID) -> Property? {
        var result = propertyStore.readObject(aID)
        
        if (result != nil) {
            result.context = self
        }
        
        return result;
    }
    
    func updateProperty(aProperty: Property) {
        propertyStore.updateObject(aProperty)
    }

    func deleteProperty(aProperty: Property) {
        propertyStore.deleteObject(aProperty)
        
        aProperty.context = nil;
    }
    
    //MARK: CR(U)D Strings / NO UPDATE
    
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
    
    func stringURLNameFor(property : Property) -> NSURL {
        return docURL.URLByAppendingPathComponent("p\(property.uid).txt")
    }
    
    // used
    func readStringFor(property : Property) -> String? {
        return String(contentsOfURL: stringURLNameFor(property), encoding: NSUTF8StringEncoding, error: nil)
    }
    
    // not used
    func writeStringData(stringData: NSData, ofProperty property : Property) {
        stringData.writeToURL(stringURLNameFor(property), atomically: true)
    }
    
    // used
    func writeString(string: String, ofProperty property : Property) {
        string.writeToURL(stringURLNameFor(property), atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }

}


/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

