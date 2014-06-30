//
//  DataStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

// #pragma mark -

// Concept requirements & implementation

// CRUD D
// - generic data
// - generic header
// - read / write header

// required "endOfFile" marker
// required "unusedDataSegments"
// register fuction



// D = a data struct
// H = a header struct

class DataStore<D, H: DataStoreHeader>  {
    
    // #pragma mark ----------------------------------------------------------------
    
    var error: NSError?  // readonly?
    
    var url: NSURL!
    var fileHandle: NSFileHandle!
    var newFile = false;
    
    var fileOffset : Int = 1
    
    // data.length + header.length;
    let headerSize = sizeof(H)
    let dataSize = sizeof(D)
    let blockSize = sizeof(H) + sizeof(D)  // test as CUnsignedLongLong
    
    var endOfFile: CUnsignedLongLong = 0;
    var unusedDataSegments =  Dictionary<CUnsignedLongLong,Bool>()
    
    // #pragma mark ----------------------------------------------------------------
    
    init(url: NSURL) {
        
        self.url = url;
        
        if !url.isFileExisting() {
            
            self.createNewFile()
            
            // TODO  add error handling
            // - out of memory
            // - no access
            //
            newFile = true
        }
        
        self.fileHandle = NSFileHandle.fileHandleForUpdatingURL(url, error: &self.error)
        self.endOfFile = self.fileHandle.seekToEndOfFile()
        
        initStore()
        readUnusedDataSegments()
    }
    
    
    // override inf subclasses
    func initStore() {
    }
    
    // override in subclasses and update fileOffset if required
    func createNewFile() -> Bool {
        // update fileOffset
        
        // FIX: why not let?
        var firstChar: Character = "X"
        var data = NSData(bytes: &firstChar, length: sizeofValue(firstChar))
        return data.writeToURL(self.url, atomically: true)
    }
    
    func readUnusedDataSegments() {
        
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
    
    
    
    // #pragma mark ----------------------------------------------------------------
    
    
    // #pragma mark - register and endofFile
    
    func seekEndOfFile() -> CUnsignedLongLong {
        return self.fileHandle.seekToEndOfFile()
    }

    
    // increase the virtual EndOfFile pointer by on dataSize
    func extendFile() -> CUnsignedLongLong {
        
        let pos = self.endOfFile
        
        self.endOfFile = pos + CUnsignedLongLong(blockSize)
        
        return pos;
    }
    
    //#pragma mark - pos Calcuation
    
    func calculatePos(aID: UID) -> CUnsignedLongLong {
        
        return CUnsignedLongLong((aID * self.blockSize) + self.fileOffset)
    
    }
    
    func calculateID(pos: CUnsignedLongLong) -> UID {
        
        var result = (Int(pos) - self.fileOffset) / self.blockSize;
        
        return result
    }
    
    func seekToFileID(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.calculatePos(aID)
        
        self.fileHandle.seekToFileOffset(pos)
        
        return pos
    }

    // #pragma mark - read/write header
    
    func readHeader() -> H! {
        
        let data = self.fileHandle.readDataOfLength(sizeof(H))
        
        // works only by value?
        if data {
            var result : H
            
            data.getBytes(&result)
            
            return result
        }
        
        return nil;
    }
    
    func writeHeader(header: CMutablePointer<H>) {
        
        let headerData = header.withUnsafePointer {
            NSData(bytes:$0, length:sizeof(H))
        }
        self.fileHandle.writeData(headerData)
    }
    
    func writeHeader(aHeader: H) {
        
        var header = aHeader
        
        var data = NSData(bytesNoCopy:&header, length:sizeof(H))
    
        self.fileHandle.writeData(data)
    }
    
    // override this methode
    func writeHeader(forData data:CMutablePointer<D>, atPos pos:CUnsignedLongLong) {
        
    }
    
    //#pragma mark - CRUD DATA
    
    subscript(index: UID) -> D! {
        get {
            self.seekToFileID(index)
            return self.readData()
        }
        
        set(newValue) {
            var pos = self.calculatePos(index)
            self.writeData(newValue, atPos: pos)
        }
    }
    
    
    // CREATE Use Case is a 2-step action
    // - register -> pos
    // - writeData:AtPos:
    
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
    
    
    // READ
        
    func readData() -> D! {
        
        var data = self.fileHandle.readDataOfLength(sizeof(D));
        
        // works only by value?
        if data {
            var result : D
            
            data.getBytes(&result)
            
            return result
        }
        
        return nil;
    }
    
    // UPDATE
    
    func writeData(data: D, atPos pos: CUnsignedLongLong) {
        
        // TODO: FIX
        var a = data
        var data = NSData(bytesNoCopy: &a, length: sizeof(D))
        
        self.fileHandle.seekToFileOffset(pos)
        self.writeHeader(forData: &a, atPos: pos)
        
        self.fileHandle.writeData(data);
    }
    
    // subclases have to override
    func deleteData(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        var header = H()
        header.used = false
        
        self.writeHeader(&header)
        
        self.unusedDataSegments[pos] = true
        
        return pos
    }
    
}