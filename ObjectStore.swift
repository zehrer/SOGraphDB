//
//  ObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

class ObjectStore<O: PersistentObject, H: DataStoreHeader> : DataStore<O.DataType,H> {
    
    //var objectType : Class!
    
    init(url: NSURL) {
        super.init(url: url)
    }
    
    func registerObject() -> UID {
        var pos = self.register()
        return self.calculateID(pos)
    }
    
    func createObject() -> O {
        
        var result = O()
        
        self.addObject(result)
        
        return result
    }
    

    func addObject(aObj: O) -> UID {
        
        var pos = self.register()
        var uid = self.calculateID(pos)
    
        self.writeData(aObj.data, atPos: pos)
        
        aObj.uid = self.calculateID(pos)
        aObj.dirty = false
        
        return uid
    }
    
    
    func readObject(aID: UID) -> O? {
        
        var data = self[aID]
        
        if data {
            var result = O()
            result.uid = aID
            
            return result
            
        }
        
        return nil;
    }

    func updateObject(aObj: O) {
        
        if aObj.dirty && aObj.uid {

            self[aObj.uid!] = aObj.data
            
            aObj.dirty = false
        }
    }
    
    func deleteObject(aObj: O) {
        
        if aObj.uid {
            self.deleteData(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
}