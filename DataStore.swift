//
//  DataStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class DataStore<O: ObjectCoding, H> : FileStore {
    
    var dataSize: Int = 0
    
    init(url: NSURL) {
        super.init(url: url)
    }

    
    // #pragma mark -

    // #pragma mark - read/write header
    
        
    func readHeader() -> H! {
        
        var data = self.fileHandle.readDataOfLength(sizeof(H))
        
        var result : H
        
        data.getBytes(&result)
        
        return result
        
    }
   
    /**
    func writeHeader(header: H) {
        
        var data = NSData(bytesNoCopy:CMutableVoidPointer(&header), length:sizeof(H))
        
        self.fileHandle.writeData(data)
        
    }*/

    // override this methode
    func writeHeader(forData data:NSData, atPos pos:CUnsignedLongLong) {
        
    }
    
    func writeHeader(buffer: CConstPointer<H>) {
        
        let headerData = buffer.withUnsafePointer {
            NSData(bytes:$0, length:sizeof(H))
        }
        self.fileHandle.writeData(headerData)
    }
        
    //#pragma mark - pos Calcuation
    
    func calculatePos(aID: UID) -> CUnsignedLongLong {
        
        return CUnsignedLongLong((aID * self.dataSize) + self.fileOffset)
    
    }
    
    func calculateID(pos: CUnsignedLongLong) -> UID {
        
        var result = (Int(pos) - self.fileOffset) / self.dataSize;
        
        return result
    }
    
    func seekToFileID(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.calculatePos(aID)
        
        self.fileHandle.seekToFileOffset(pos)
        
        return pos
    }

    //#pragma mark - SOFileStore
    
    override func write(data: NSData, atPos pos: CUnsignedLongLong) {
        
        self.fileHandle.seekToFileOffset(pos)
        
        self.writeHeader(forData: data, atPos: pos)

        self.fileHandle.writeData(data);
    }
    
    override func writeAtEndOfFile(data: NSData) -> CUnsignedLongLong {
        
        let pos = self.endOfFile()

        self.write(data, atPos: pos)
        
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
        
        var pos = self.seekToFileID(aID)
        
        self.write(data, atPos: pos)
    }

    func delete(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        return pos;
    }
    
}