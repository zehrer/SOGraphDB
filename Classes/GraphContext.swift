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
    
    var nodeStore: SOCacheDataStore!
    var relationshipStore: SOCacheDataStore!
    var propertyStore: SOCacheDataStore!
    var stringStore: SOStringDataStore!
    
    //#pragma mark -
    
    init(url: NSURL) {
        self.url = url
    }

    func setCacheLimit(newValue: Int) {
        self.nodeStore.cache.countLimit = newValue
        self.relationshipStore.cache.countLimit = newValue
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
    }

}


// add temporary feature
// delete data wrapper after closing the context
// perfect for test's


/**

@interface SOGraphContext : NSObject

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) NSURL *url;

#pragma mark -

- (instancetype)initWithURL:(NSURL *)aURL;

- (void)setCacheLimit:(NSInteger)limit;
- (void)setCacheDelegate:(id<NSCacheDelegate>)cacheDelegate;

#pragma mark - Transaction Handling

/**
- (NSNumber *)startTransaktion;
- (void)endTransaktion:(NSNumber *)transactionID;
*/

#pragma mark - CRUD Node

// No add method, node has no parameter they need just created
- (SONode *)createNode;

- (SONode *)readNode:(NSNumber *)aID;

- (void)updateNode:(SONode *)aObj;

- (void)deleteNode:(SONode *)aObj;

#pragma mark - CRUD Relationship (C = Add)

- (void)registerRelationship:(SORelationship *)aObj;

- (void)addRelationship:(SORelationship *)aObj;

- (SORelationship *)readRelationship:(NSNumber *)aID;

- (void)updateRelationship:(SORelationship *)aObj;

- (void)deleteRelationship:(SORelationship *)aObj;

#pragma mark - CRUD Property (C = Add)

- (void)registerProperty:(SOProperty *)aObj;

- (void)addProperty:(SOProperty *)aObj;

- (SOProperty *)readProperty:(NSNumber *)aID;

- (void)updateProperty:(SOProperty *)aObj;

- (void)deleteProperty:(SOProperty *)aObj;

#pragma mark - CRD Strings (C = Add)

- (NSNumber *)addString:(NSString *)text;

- (NSString *)readStringAtIndex:(NSNumber *)aIndex;

- (void)deleteStringAtIndex:(NSNumber *)aIndex;

*/