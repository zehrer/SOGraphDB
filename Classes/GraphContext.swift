//
//  GraphContext.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

let cNodeStoreFileName         = "nodestore.db";
let cRelationshipStoreFileName = "relation.db";
let cPropertyStoreFileName     = "property.db";
let cStringStoreFileName       = "stringstore.db";

public class GraphContext {
    
    let url: NSURL
    public var error: NSError?  // readonly?
    var temporary = false  // // delete data wrapper after closing the context
    
    var nodeStore: ObjectDataStore<Node>!
    var relationshipStore: ObjectDataStore<Relationship>!
    var propertyStore: ObjectDataStore<Property>!
    var stringStore: StringStore!
    
    //#pragma mark -
    
    public init(url: NSURL) {
        self.url = url
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

    func setupFileStores() {
        
        var error : NSError?
        
        var directoryFileWrapper: NSFileWrapper? = NSFileWrapper(URL: url, options:.Immediate, error:&error);
        
        if let fileWrapper = directoryFileWrapper {
            if fileWrapper.directory {
                return;
            }
        } else {
            // ex
            var fileManager = NSFileManager.defaultManager()
            
            error = nil;  // remove file not found error
            //fileManager.createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
            
            fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error:&error)
            
            
            // TODO
            self.error = error;
        }
        
        var nodeStoreURL = url.URLByAppendingPathComponent(cNodeStoreFileName)
        nodeStore = ObjectDataStore<Node>(url: nodeStoreURL)
        nodeStore.cache.name = "nodeStore"  // TODO: automate
        
        var relationshipStoreURL = url.URLByAppendingPathComponent(cRelationshipStoreFileName)
        relationshipStore = ObjectDataStore<Relationship>(url:relationshipStoreURL)
        //relationshipStore.setupStore(SORelationship())
        nodeStore.cache.name = "relationshipStore"
        
        var propertyStoreURL = url.URLByAppendingPathComponent(cPropertyStoreFileName)
        propertyStore = ObjectDataStore<Property>(url: propertyStoreURL)
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
    func createNode() -> Node {
        
        // TODO should support generics
        let result = nodeStore.createObject() as Node
        
        result.context = self
        
        return result;
    }
    
    func readNode(aID: UID) -> Node? {
        
        //NSParameterAssert(aID != 0);
        
        var result : Node? = nodeStore.readObject(aID)
        
        if (result != nil) {
            result!.context = self
        }
        
        return result;
    }
    
    func updateNode(aNode: Node) {
        nodeStore.updateObject(aNode)
    }

    func deleteNode(aNode: Node) {
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

    func readRelationship(uid:UID) -> Relationship? {
        
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
    
    func readProperty(aID:UID) -> Property? {
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

}


/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

