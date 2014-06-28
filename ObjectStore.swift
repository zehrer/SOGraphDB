//
//  ObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

// TODO 
// HEADER = H
// OBJECT = O

class ObjectStore<O: ObjectCoding, H: Coding> : DataStore<H> {
    
    //var objectType : Class!
    
    init(url: NSURL) {
        super.init(url: url)
    }
    
    func createObject() -> O {
        
        var result: O = O()
        
        self.addObject(result)
        
        return result
    }
    

    func addObject(aObj: O) -> UID {
        
        aObj.uid = self.create(aObj.encodeData())
        
        aObj.dirty = false
        
        return aObj.uid!
    }
    
    
    func readObject(aID: UID) -> O? {
        
        var data = self.read(aID)
        
        if data.length > 0 {
            var result = O(data: data)
            result.uid = aID
            
            return result
            
        }
        
        return nil;
    }

    func updateObject(aObj: O) {
        
        if aObj.dirty {
            var data = aObj.encodeData()
        
            //self.update(data, atID:aObj.id)
            
            aObj.dirty = false
        }
    }
    
    func deleteObject(aObj: O) {
        
        if aObj.uid {
            self.delete(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
}