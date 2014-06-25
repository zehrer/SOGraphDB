//
//  DataStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class DataStore<H: Coding> : FileStore {
    
    var dataSize: Int = 0
    var headerSize: Int = 0
    
    init(url: NSURL) {
        super.init(url: url)
    }

    
    // #pragma mark -

    // #pragma mark - read/write header
    
        
    func readHeader() -> NSData! {
        return self.fileHandle.readDataOfLength(self.headerSize)
    }
    
   
    func writeHeader() {
        
    }
    
    func readHeader(buffer: CMutableVoidPointer) {
        //NSParameterAssert(self.headerSize);
        
        var header: NSData = self.readHeader()
        
        header.getBytes(buffer)
    }
    
    func writeHeader(buffer: CMutableVoidPointer) {
        //NSParameterAssert(self.headerSize);
        
        var headerData = NSData(bytesNoCopy:buffer, length:Int(self.headerSize))
        self.fileHandle.writeData(headerData)
    }
    
    //#pragma mark - pos Calcuation
    
    func calculatePos(UID: Identifier) -> CUnsignedLongLong {
        
        return CUnsignedLongLong((UID * self.dataSize) + self.fileOffset)
        
        // (aID.unsignedIntValue * self.dataSize) + self.fileOffset;

    }
    
    func calculateID(pos: CUnsignedLongLong) -> Identifier {
        // unsigned long long result = (pos - self.fileOffset) / self.dataSize;
        
        var result = (Int(pos) - self.fileOffset) / self.dataSize;
        
        return result
    }
    
    func seekToFileID(UID: Identifier) -> CUnsignedLongLong {
        //  NSParameterAssert(UID);
        
        var pos = self.calculatePos(UID)
        
        self.fileHandle.seekToFileOffset(pos)
        
        return pos
    }

    //#pragma mark - SOFileStore
    
    override func write(data: NSData, atPos pos: CUnsignedLongLong) {
        
        self.fileHandle.seekToFileOffset(pos)
        
        self.writeHeader()

        self.fileHandle.writeData(data);
    }
    
    override func writeAtEndOfFile(data: NSData) -> CUnsignedLongLong {
        
        let pos = self.endOfFile()
        
        self.writeHeader()
        
        self.fileHandle.writeData(data)
        
        return pos;
    }

    //#pragma mark - CRUD Data
    
    func create(data: NSData) -> Identifier {
        
        let pos = self.writeAtEndOfFile(data)
        
        return self.calculateID(pos)
    }

    func readData() -> NSData {
        return self.fileHandle.readDataOfLength(Int(self.dataSize));
    }
    
    func readData(length: UInt64) -> NSData {
        return self.fileHandle.readDataOfLength(Int(length))
    }

    
    func read(aID: Identifier) -> NSData {
        self.seekToFileID(aID)
        
        return self.readData()
    }

    
    func update(data: NSData, atID aID:Identifier) {
        self.seekToFileID(aID)
        
        // dynamic header?
        self.writeHeader()
        
        self.fileHandle.writeData(data)
    }

    func delete(aID: Identifier) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        return pos;
    }
    
}