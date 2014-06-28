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
    
    func calculatePos(aID: UID) -> CUnsignedLongLong {
        
        return CUnsignedLongLong((aID * self.dataSize) + self.fileOffset)
        
        // (aID.unsignedIntValue * self.dataSize) + self.fileOffset;

    }
    
    func calculateID(pos: CUnsignedLongLong) -> UID {
        // unsigned long long result = (pos - self.fileOffset) / self.dataSize;
        
        var result = (Int(pos) - self.fileOffset) / self.dataSize;
        
        return result
    }
    
    func seekToFileID(aID: UID) -> CUnsignedLongLong {
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
    
    func create(data: NSData) -> UID {
        
        let pos = self.writeAtEndOfFile(data)
        
        return self.calculateID(pos)
    }

    func readData() -> NSData {
        return self.fileHandle.readDataOfLength(Int(self.dataSize));
    }
    
    func readData(length: UInt64) -> NSData {
        return self.fileHandle.readDataOfLength(Int(length))
    }

    
    func read(aID: UID) -> NSData {
        self.seekToFileID(aID)
        
        return self.readData()
    }

    
    func update(data: NSData, atID aID:UID) {
        self.seekToFileID(aID)
        
        // dynamic header?
        self.writeHeader()
        
        self.fileHandle.writeData(data)
    }

    func delete(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        return pos;
    }
    
}