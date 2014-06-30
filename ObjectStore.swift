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

class ObjectStore<O: PersistentObject> : DataStore<ObjectStoreHeader,O.DataType> {
    
    //var objectType : Class!
    
    init(url: NSURL) {
        super.init(url: url)
    }
    
    // subclasses should overide this method
    // Create a file store element with the ID:0
    // ID 0 is not allowd to use in the store because
    override func initStore() {
        
        if self.newFile {
            
            // store SampleData as ID:0 in the file
            // ID:0 is a reserved ID and should not be availabled for public access
            
            let aObj = O()
            
            var header = ObjectStoreHeader(used: false)
   
            self.writeHeader(&header)
            self.writeData(aObj.data, atPos: CUnsignedLongLong(self.fileOffset))
            
        }
        
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