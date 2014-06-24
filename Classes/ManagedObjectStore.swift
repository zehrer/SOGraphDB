//
//  ManagedObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 22.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

struct HEADER {
    var used: Bool = true;
}

class ManagedObjectStore<T: Coding> : ObjectStore<T> {
    
    var header: NSData
    var deleteHeader: NSData

    var  endOfFile: CUnsignedLongLong = 0;
    
    var unusedDataSegments =  Dictionary<CUnsignedLongLong,Bool>()

    init(url: NSURL) {
    
        var header = HEADER()
        
        self.header = NSData(bytes:&header, length:sizeof(HEADER));
        header.used = false;
        self.deleteHeader = NSData(bytes:&header, length:sizeof(HEADER));
        
        super.init(url: url)
        
        // set virtual file end to offSet because initStore use the register methode
        //self.endOfFile = CUnsignedLongLong(self.fileOffset)
        
        self.dataSize = sizeof(HEADER) + sizeof(T)
        
        self.endOfFile = self.fileHandle.seekToEndOfFile()
        
        self.readUnusedDataSegments()
        self.initStore()
    }
    
    func readUnusedDataSegments() {
        
        let headerSize = sizeof(HEADER)
        
        
        var pos = CUnsignedLongLong(self.fileOffset)
        
        self.fileHandle.seekToFileOffset(pos)
    
        var header = HEADER()
        var headerData : NSData? = nil
        
        while (pos < self.endOfFile) {
            // reade the complete file
            
            headerData = readHeader()
            headerData?.getBytes(&header, length:headerSize)
            
            self.fileHandle.readDataOfLength(self.dataSize)
            
            if !header.used {
                // add pos into the special dictionary
                self.unusedDataSegments[pos] = true
            }
            
            pos = self.fileHandle.offsetInFile
        }
    }
    

    func initStore() {
        
    }


    // increase the virtual EndOfFile pointer by on dataSize
    func extendFile() -> CUnsignedLongLong {
        
        let pos = self.endOfFile
        
        self.endOfFile = pos + CUnsignedLongLong(sizeof(T))
        
        return pos;
    }

    
    
    //#pragma mark - read/write Header
        
    override func readHeader() -> NSData! {
        return self.fileHandle.readDataOfLength(self.header.length)
    }
    

    override func writeHeader() {
        self.fileHandle.writeData(self.header)
    }
    
    //#pragma mark - OVERRIDE SODataStore methodes
        
        
    func readData() -> NSData? {
        
        var header = HEADER()
        
        var aHeader: NSData! = self.readHeader()
        aHeader.getBytes(&header, length:sizeof(HEADER))
        
        if header.used {
            return self.fileHandle.readDataOfLength(sizeof(T))
        }
        
        return nil
    }

    
    override func delete(aID: Identifier) -> CUnsignedLongLong {
        
        var pos = super.delete(aID)
        
        self.fileHandle.writeData(self.deleteHeader)
        
        self.unusedDataSegments[pos] = true;
        
        return pos;
        
    }
    
    //#pragma mark - CRUD Data

    func register() -> CUnsignedLongLong {
        
        var pos: CUnsignedLongLong? = Array(unusedDataSegments.keys)[0]
        
        if pos {
            //self.unusedDataSegments removeObject:unusedSegmentPos];
            self.unusedDataSegments[pos!] = nil;
        } else {
            pos = self.extendFile()
        }
        
        return pos!;
    }
    
    override func create(data: NSData) -> Identifier  {
        
        let pos = self.register()
        
        self.write(data, atPos: pos)
        
        return self.calculateID(pos)
        
    }
    
    // #pragma mark - CRUD Objects
    
    func registerObject(inout aObj: T) -> Identifier? {
        
        if aObj.dirty {
            // only NEW object can be registered,
            // flag don't show 100% if it is new but at least a information which is available
            
            var pos = self.register()
            
            aObj.uid = self.calculateID(pos)
            
            return aObj.uid
            
        }
        
        return nil;
    }

    
}
