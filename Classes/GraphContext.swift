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

class GraphContext {
    
    let url: NSURL
    var error: NSError?  // readonly?
    var temporary = false  // // delete data wrapper after closing the context
    
    var nodeStore: SOCacheDataStore!
    var relationshipStore: SOCacheDataStore!
    var propertyStore: SOCacheDataStore!
    var stringStore: SOStringDataStore!
    
    //#pragma mark -
    
    init(url: NSURL) {
        self.url = url
        setupFileStores()
    }

    deinit {
        
        // should close all files
        self.nodeStore = nil;
        self.relationshipStore = nil;
        self.propertyStore = nil;
        self.stringStore = nil;
        
        if temporary {
            url.deleteFile()
            NSLog("GraphContext file wrapper was deleted because temporary was enabled")
        }
    }

    func setupFileStores() {
        
        var error : NSError?
        
        var directoryFileWrapper: NSFileWrapper? = NSFileWrapper(URL: self.url, options:.Immediate, error:&error);
        
        if let fileWrapper = directoryFileWrapper {
            if fileWrapper.directory {
                return;
            }
        } else {
            // ex
            var fileManager = NSFileManager.defaultManager()
            
            error = nil;  // remove file not found error
            //fileManager.createDirectoryAtURL:self.url withIntermediateDirectories:YES attributes:nil error:&error];
            
            fileManager.createDirectoryAtURL(self.url, withIntermediateDirectories: true, attributes: nil, error:&error)
            
            
            // TODO
            self.error = error;
        }
        
        var nodeStoreURL = self.url.URLByAppendingPathComponent(cNodeStoreFileName)
        self.nodeStore = SOCacheDataStore(URL: nodeStoreURL)
        self.nodeStore.setupStore(SONode())
        self.nodeStore.cache.name = "nodeStore"
        
        var relationshipStoreURL = self.url.URLByAppendingPathComponent(cRelationshipStoreFileName)
        self.relationshipStore = SOCacheDataStore(URL:relationshipStoreURL)
        self.relationshipStore.setupStore(SORelationship())
        self.nodeStore.cache.name = "relationshipStore"
        
        var propertyStoreURL = self.url.URLByAppendingPathComponent(cPropertyStoreFileName)
        self.propertyStore = SOCacheDataStore(URL: propertyStoreURL)
        self.propertyStore.setupStore(SOProperty())
        self.propertyStore.cache.name = "propertyStore"
        
        var stringStoreURL = self.url.URLByAppendingPathComponent(cStringStoreFileName)
        self.stringStore = SOStringDataStore(URL:stringStoreURL)
    }
    
    func setCacheLimit(newValue: Int) {
        self.nodeStore.cache.countLimit = newValue
        self.relationshipStore.cache.countLimit = newValue
    }
    
    func setCacheDelegate(newValue: NSCacheDelegate) {
        self.nodeStore.cache.delegate = newValue;
        self.relationshipStore.cache.delegate = newValue;
        self.propertyStore.cache.delegate = newValue;
    }
    
    //#pragma mark - CRUD Node
    
    // No add method, node has no parameter they need just created
    func createNode() -> SONode {
        
        // TODO should support generics
        let result = self.nodeStore.createObject() as SONode
        
        //TODO
        //result.context = self
        
        return result;
    }
    
    func readNode(aID: UInt64) -> SONode? {
        
        //NSParameterAssert(aID != 0);
        
        var result : SONode? = nil //self.nodeStore.readObject(aID)
        
        //TODO
        //result.context = self
        
        return result;
    }
    
    func updateNode(aNode: SONode) {
        self.nodeStore.updateObject(aNode)
    }

    func deleteNode(aNode: SONode) {
        self.nodeStore.deleteObject(aNode)
        
        aNode.context = nil;
    }

    
    // #pragma mark - CRUD Relationship
    
    func updateRelationship(aRelationship: SORelationship) {
        self.relationshipStore.updateObject(aRelationship)
    }
    
    func deleteProperty(aRelationship: SORelationship) {
        self.relationshipStore.deleteObject(aRelationship)
        
        aRelationship.context = nil;
    }

    // #pragma mark - CRUD Property
    
    
    func updateProperty(aProperty: SOProperty) {
        self.propertyStore.updateObject(aProperty)
    }

    func deleteProperty(aProperty: SOProperty) {
        self.propertyStore.deleteObject(aProperty)
        
        aProperty.context = nil;
    }
    
    //#pragma mark - CRD Strings
    
    
    func addString(text: String) -> Int {
        let num =  self.stringStore.addString(text)
        
        // TODO
        return num.integerValue;
    }
    
    func readStringAtIndex(index: UInt) -> String? {
        return self.stringStore.readStringAtIndex(index)
    }

    func deleteStringAtIndex(index: UInt) {
        self.stringStore.deleteStringAtIndex(index)
    }

}



/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

