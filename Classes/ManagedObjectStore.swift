//
//  ManagedObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 22.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


/**
struct ObjectStoreHeader : DataStoreHeader  {
    var used: Bool = true;
    
}
*/

class ManagedObjectStore<O: PersistentObject> : ObjectDataStore<O> {
    
    //var header: NSData
    //var deleteHeader: NSData

    init(url: NSURL) {
    
        //var header: ObjectStoreHeader  = ObjectStoreHeader(used:true)
        
        //self.header = NSData(bytes:&header, length:sizeof(ObjectStoreHeader));
        //header.used = false;
        //self.deleteHeader = NSData(bytes:&header, length:sizeof(ObjectStoreHeader));
        
        super.init(url: url)
        
        // set virtual file end to offSet because initStore use the register methode
        //self.endOfFile = CUnsignedLongLong(self.fileOffset)
        
        //self.dataSize = sizeof(HEADER) + sizeof(O)
        
        //self.endOfFile = self.fileHandle.seekToEndOfFile()
        
        //self.readUnusedDataSegments()
        //self.initStore()
    }
     /**
    
    func readUnusedDataSegments() {
        
        let headerSize = sizeof(ObjectStoreHeader)
        let dataSize = self.blockSize - headerSize
        
        var pos = CUnsignedLongLong(self.fileOffset)
        
        self.fileHandle.seekToFileOffset(pos)
 
        while (pos < self.endOfFile) {
            // reade the complete file
            
            let header = readHeader()
            
            self.fileHandle.readDataOfLength(dataSize)
            
            if !header.used {
                // add pos into the special dictionary
                self.unusedDataSegments[pos] = true
            }
            
            pos = self.fileHandle.offsetInFile
        }
    }
    

    
    // subclasses should overide this method
    // Create a file store element with the ID:0
    // ID 0 is not allowd to use in the store because
    func initStore() {
        
        if self.newFile {
            
            // store SampleData as ID:0 in the file
            // ID:0 is a reserved ID and should not be availabled for public access

            let aObj = O()
            
            var header = ObjectStoreHeader(used: false)
            
            self.writeHeader(&header)
            self.writeData(aObj.data, atPos: CUnsignedLongLong(self.fileOffset))
            
        }
        
    }
    
    
    //#pragma mark - read/write Header
    
   
    override func writeHeader(forData data: NSData, atPos pos: CUnsignedLongLong) {
        self.fileHandle.writeData(self.header)
    }

    
    //#pragma mark - OVERRIDE SODataStore methodes
    
    
    
    func readData() -> NSData? {
        
        let header = readHeader()
        
        if header.used {
            return readData()
        }
        
        return nil
    }
    
    
    override func delete(aID: UID) -> CUnsignedLongLong {
        
        var pos = super.delete(aID)
        
        self.fileHandle.writeData(self.deleteHeader)
        
        self.unusedDataSegments[pos] = true;
        
        return pos;
        
    }
    
    
    //#pragma mark - CRUD Data


    
    override func create(data: NSData) -> UID  {
        
        let pos = self.register()
        
        self.write(data, atPos: pos)
        
        return self.calculateID(pos)
        
    }



    // #pragma mark - CRUD Objects
    
    func registerObject(aObj: O) -> UID? {
        
        if aObj.dirty {
            // only NEW object can be registered,
            // flag don't show 100% if it is new but at least a information which is available
            
            var pos = self.register()
            
            aObj.uid = self.calculateID(pos)
            
            return aObj.uid
            
        }
        
        return nil;
    }    
*/
}
