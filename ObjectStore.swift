//
//  ObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class ObjectStore<T: Coding> : DataStore {
    
    //var objectType : Class!
    
    init(url: NSURL) {
        super.init(url: url)
    }
    
    func createObject() -> T {
        
        var result: T = T()
        
        self.addObject(&result)
        
        return result
    }
    

    func addObject(inout aObj: T) -> Identifier {
        
        aObj.uid = self.create(aObj.encodeData())
        
        aObj.dirty = false
        
        return aObj.uid!
    }
    
    
    func readObject(aID: Identifier) -> T? {
        
        var data = self.read(aID)
        
        if data.length > 0 {
            var result = T(data: data)
            result.uid = aID
            
            return result
            
        }
        
        return nil;
    }

    func updateObject(inout aObj: T) {
        
        if aObj.dirty {
            var data = aObj.encodeData()
        
            //self.update(data, atID:aObj.id)
            
            aObj.dirty = false
        }
    }
    
    func deleteObject(inout aObj: T) {
        //self.delete(aObj.id)
        aObj.uid = nil;
    }
    
}