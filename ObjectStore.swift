//
//  ObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class ObjectStore<T: SOCoding> : DataStore {
    
    //var objectType : Class!
    
    func createObject() -> T {
        
        var result: T = T(data: nil)
        
        self.addObject(result)
        
        return result
    }
    

    func addObject(aObj: T) -> NSNumber {
        
        //aObj.id = create(aObj.encodeData())
        
        aObj.isDirty = false
        
        return aObj.id
    }
    
    
    func readObject(aID: UInt64) -> T? {
        
        var result: T? = nil;
        
        var data = self.read(aID)
        
        if data.length > 0 {
            result = T(data: data)
            
           // result.?.id = aID
            
        }
        
        return result;
    }

    func updateObject(aObj: T) {
        
        if aObj.isDirty {
            var data = aObj.encodeData()
        
            //self.update(data, atID:aObj.id)
            
            aObj.isDirty = false
        }
    }
    
    func deleteObject(aObj: T) {
        //self.delete(aObj.id)
        aObj.id = nil;
    }
    
}