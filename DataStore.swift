//
//  DataStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class DataStore : FileStore {
    
    var dataSize: UInt64 = 0
    var headerSize: UInt64 = 0
    
    
    // #pragma mark -

    // #pragma mark - read/write header
    
        
    func readHeader() -> NSData! {
        return self.fileHandle.readDataOfLength(Int(self.headerSize))
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
    
    func calculatePos(aID: UInt64) -> CUnsignedLongLong {
        
        return (aID * self.dataSize) + self.fileOffset
        
        // (aID.unsignedIntValue * self.dataSize) + self.fileOffset;

    }
    
    func calculateID(pos: CUnsignedLongLong) -> UInt64 {
        // unsigned long long result = (pos - self.fileOffset) / self.dataSize;
        
        var result = (pos - self.fileOffset) / self.dataSize;
        
        return result
    }
    
    func seekToFileID(aID: UInt64) -> CUnsignedLongLong {
        //  NSParameterAssert(aID);
        
        var pos = self.calculatePos(aID)
        
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
    
    func create(data: NSData) -> UInt64 {
        
        let pos = self.writeAtEndOfFile(data)
        
        return self.calculateID(pos)
    }

    func readData() -> NSData {
        return self.fileHandle.readDataOfLength(Int(self.dataSize));
    }
    
    func readData(length: UInt64) -> NSData {
        return self.fileHandle.readDataOfLength(Int(length))
    }

    
    func read(aID: UInt64) -> NSData {
        self.seekToFileID(aID)
        
        return self.readData()
    }

    
    func update(data: NSData, atID aID:UInt64) {
        self.seekToFileID(aID)
        
        // dynamic header?
        self.writeHeader()
        
        self.fileHandle.writeData(data)
    }

    func delete(aID: UInt64) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        return pos;
    }
    
}