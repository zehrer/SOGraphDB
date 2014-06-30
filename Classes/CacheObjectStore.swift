//
//  CacheObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 25.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class CacheObjectStore<O:ObjectCoding>: ObjectStore<O>  {

    let cache = NSCache();
    
    
    override func createObject() -> O {
        
        let result = super.createObject()
        
        let uid: NSNumber = result.uid!
        
        self.cache.setObject(result, forKey: uid)
        
        return result
    }
    
    override func addObject(aObj: O) -> UID {
        
        aObj.uid = self.create(aObj.encodeData())
        
        self.cache .setObject(aObj, forKey: aObj.uid)
        
        return aObj.uid!
    }

    
    override func readObject(aID: UID) -> O? {
        
        var result = self.cache.objectForKey(aID) as O?
        
        if !result {
            result = super.readObject(aID)
            
            if result {
                self.cache.setObject(result, forKey: aID)
            }
        }
        
        return result
    }

     // version with cache support
    override func deleteObject(aObj: O) {
        self.cache.removeObjectForKey(aObj.uid)
        super.deleteObject(aObj)
    }

    override func registerObject(aObj: O) -> UID? {
        
        var result = super.registerObject(aObj)
        
        if result {
            self.cache.setObject(aObj, forKey: result)
        }
        
        return result
    }
}
