//
//  FileStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

class FileStore {
    
    var error: NSError?  // readonly?
    
    var url: NSURL!
    var fileHandle: NSFileHandle!
    var newFile = false;
    
    var fileOffset : Int = 1
    
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
    }

    
    func createNewFile() -> Bool {
        var firstChar: Character = "A"
        var data = NSData(bytes: &firstChar, length: sizeofValue(firstChar))
        return data.writeToURL(self.url, atomically: true)
    }
    
    
    //#pragma mark - CRUD Data
    
    func endOfFile() -> CUnsignedLongLong {
        return self.fileHandle.seekToEndOfFile()
    }
    
    
    func write(data: NSData, atPos pos: CUnsignedLongLong) {
        self.fileHandle.seekToFileOffset(pos)
        
        self.fileHandle.writeData(data)
    }

    func writeAtEndOfFile(data: NSData) -> CUnsignedLongLong {
        
        let pos = self.endOfFile()
        
        self.fileHandle.writeData(data)
        
        return pos
    }
    
    func read(length: Int, atPos pos:CUnsignedLongLong) -> NSData {
        self.fileHandle.seekToFileOffset(pos)
        
        return self.fileHandle.readDataOfLength(length)
    }

}