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
    
    var nodeStore: ObjectStore<Node>!
    var relationshipStore: ObjectStore<Relationship>!
    var propertyStore: ObjectStore<Property>!
    var stringStore: StringStore!
    
    //#pragma mark -
    
    public init(url: NSURL) {
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
        self.nodeStore = ObjectStore<Node>(url: nodeStoreURL)
        self.nodeStore.cache.name = "nodeStore"  // TODO: automate
        
        var relationshipStoreURL = self.url.URLByAppendingPathComponent(cRelationshipStoreFileName)
        self.relationshipStore = ObjectStore<Relationship>(url:relationshipStoreURL)
        //self.relationshipStore.setupStore(SORelationship())
        self.nodeStore.cache.name = "relationshipStore"
        
        var propertyStoreURL = self.url.URLByAppendingPathComponent(cPropertyStoreFileName)
        self.propertyStore = ObjectStore<Property>(url: propertyStoreURL)
        //self.propertyStore.setupStore(SOProperty())
        self.propertyStore.cache.name = "propertyStore"
        
        var stringStoreURL = self.url.URLByAppendingPathComponent(cStringStoreFileName)
        self.stringStore = StringStore(url:stringStoreURL)
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
    
    // MARK: CRUD Node
    
    // No add method, node has no parameter they need just created
    func createNode() -> Node {
        
        // TODO should support generics
        let result = self.nodeStore.createObject() as Node
        
        //TODO
        //result.context = self
        
        return result;
    }
    
    func readNode(aID: UInt64) -> Node? {
        
        //NSParameterAssert(aID != 0);
        
        var result : Node? = nil //self.nodeStore.readObject(aID)
        
        //TODO
        //result.context = self
        
        return result;
    }
    
    func updateNode(aNode: Node) {
        self.nodeStore.updateObject(aNode)
    }

    func deleteNode(aNode: Node) {
        self.nodeStore.deleteObject(aNode)
        
        aNode.context = nil;
    }

    // MARK: CRUD Relationship
    
    func registerRelationship(aRelationship: Relationship) {
        self.relationshipStore.registerObject(aRelationship)
        
        aRelationship.context = self
    }
    
    func updateRelationship(aRelationship: Relationship) {
        self.relationshipStore.updateObject(aRelationship)
    }
    
    func deleteProperty(aRelationship: Relationship) {
        self.relationshipStore.deleteObject(aRelationship)
        
        aRelationship.context = nil;
    }

    // MARK:  CRUD Property
    
    func updateProperty(aProperty: Property) {
        self.propertyStore.updateObject(aProperty)
    }

    func deleteProperty(aProperty: Property) {
        self.propertyStore.deleteObject(aProperty)
        
        aProperty.context = nil;
    }
    
    //MARK: CR(U)D Strings / NO UPDATE
    
    func addString(text: String) -> UID {
        let num =  self.stringStore[text]
        
        // TODO
        return num;
    }
    
    func readStringAtIndex(index: UID) -> String? {
        return self.stringStore[index]
    }

    func deleteStringAtIndex(index: UID) {
        self.stringStore[index] = nil
    }

}



/**
#pragma mark - Transaction Handling

- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

