//
//  ObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

struct ObjectStoreHeader : DataStoreHeader  {

    var used: Bool = true;
    
}

class ObjectStore<O: Coding> : DataStore<ObjectStoreHeader,O.DataType> {
    
    let cache = NSCache();
    
    override init(url: NSURL) {
        super.init(url: url)
    }
    
    // subclasses should overide this method
    // Create a block with the ID:0
    // ID 0 is not allowd to use in the store because
    override func initStore() {
        // store SampleData as ID:0 in the file
        // ID:0 is a reserved ID and should not be availabled for public access
        var header = ObjectStoreHeader(used: false)
        self.writeHeader(header)
        
        let sampleData = O()
        self.writeData(sampleData.data)
    }
    
    func registerObject(aObj: O) -> UID? {
        
        var result: UID? = nil
        
        if aObj.uid == nil {
            // only NEW object have a nil uid
            
            var pos  = self.registerBlock()
            result = self.calculateID(pos)
            aObj.uid = result
            
            self.cache.setObject(aObj, forKey: result!)
         
        }
        
        return result;
    }
    
    func createObject() -> O {
        
        var result = O()

        self.addObject(result)
        
        return result
    }
    
    func addObject(aObj: O) -> UID {
        
        var pos = registerBlock()
        var uid = calculateID(pos)
    
        self.writeBlock(aObj.data, atPos: pos)
        
        aObj.uid = uid
        aObj.dirty = false
        
        self.cache.setObject(aObj, forKey: uid)
        
        return uid
    }
    
    func readObject(aID: UID) -> O? {
        
        var result = self.cache.objectForKey(aID) as O?
        
        if result == nil {
            // not in cache
            
            var data = self[aID]  // reade data
            
            if (data != nil) {
                
                var result = O(data: data)
                result.uid = aID
                
                self.cache.setObject(result, forKey: aID)
            }
        }
        
        return result
    }

    func updateObject(aObj: O) {
        
        if aObj.dirty && aObj.uid != nil {

            self[aObj.uid!] = aObj.data
            
            aObj.dirty = false
        }
    }
    
    func deleteObject(aObj: O) {
        
        if aObj.uid != nil {
            self.cache.removeObjectForKey(aObj.uid!)
            self.deleteBlock(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
}