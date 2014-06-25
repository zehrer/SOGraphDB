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

class ObjectStore<O: Coding, H: Coding> : DataStore<H> {
    
    //var objectType : Class!
    
    init(url: NSURL) {
        super.init(url: url)
    }
    
    func createObject() -> O {
        
        var result: O = O()
        
        self.addObject(&result)
        
        return result
    }
    

    func addObject(inout aObj: O) -> Identifier {
        
        aObj.uid = self.create(aObj.encodeData())
        
        aObj.dirty = false
        
        return aObj.uid!
    }
    
    
    func readObject(aID: Identifier) -> O? {
        
        var data = self.read(aID)
        
        if data.length > 0 {
            var result = O(data: data)
            result.uid = aID
            
            return result
            
        }
        
        return nil;
    }

    func updateObject(inout aObj: O) {
        
        if aObj.dirty {
            var data = aObj.encodeData()
        
            //self.update(data, atID:aObj.id)
            
            aObj.dirty = false
        }
    }
    
    func deleteObject(inout aObj: O) {
        //self.delete(aObj.id)
        aObj.uid = nil;
    }
    
}