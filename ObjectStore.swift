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

public class ObjectStore<O: Coding> : DataStore<ObjectStoreHeader,O.DataType> {
    
    let cache = NSCache() //SOTypedCache<O>()
    
    public override init(url: NSURL) {
        super.init(url: url)
    }
    
    // subclasses should overide this method
    // Create a block with the ID:0
    // ID 0 is not allowd to use in the store because
    override func initStore() {
        
        registerBlock()
        
        // store SampleData as ID:0 in the file
        // ID:0 is a reserved ID and should not be availabled for public access
        var header = ObjectStoreHeader(used: false)
        self.writeHeader(header)
        
        var sampleData = O()
        sampleData.uid = 0
        self.writeData(sampleData.data)
    }
    
    public func registerObject(aObj: O) -> UID? {
        
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
    
    public func createObject() -> O {
        
        var result = O()

        self.addObject(result)
        
        return result
    }
    
    public func addObject(aObj: O) -> UID {
        
        var pos = registerBlock()
        var uid = calculateID(pos)
    
        self.writeBlock(aObj.data, atPos: pos)
        
        aObj.uid = uid
        aObj.dirty = false
        
        //var key = NSNumber(long: uid)
        //cache.setObject(aObj, forKey: key)
        
        return uid
    }
    
    public func readObject(aID: UID) -> O! {
        
        //var key = NSNumber(long: aID) // Workaround for the Swift bridge
        var result :O! = nil //cache.objectForKey(key) as O!
        
        if result == nil {
            // not in cache
            
            var data = self[aID]  // read data
            
            if (data != nil) {
                
                result = O(data: data)
                result.uid = aID
                
                //var key = NSNumber(long: uid)
                //self.cache.setObject(result, forKey: key)
            }
        }
        
        return result
    }

    public func updateObject(aObj: O) {
        
        if aObj.dirty && aObj.uid != nil {

            self[aObj.uid!] = aObj.data
            
            aObj.dirty = false
        }
    }
    
    public func deleteObject(aObj: O) {
        
        if aObj.uid != nil {
            //cache.removeObjectForKey(aObj.uid!)
            self.deleteBlock(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
}