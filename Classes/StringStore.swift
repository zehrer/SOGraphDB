//
//  StringStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 29.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


struct StringStoreHeader : DataStoreHeader {
    
    var used: Bool = true;            // 1
    var isUTF8Encoding: Bool = true;    // 1  <- yes string usues UTF8 / NO == UTF16
    
    var bufferLength : UInt8 = 0;       // 1Byte
    var nextStringID : UID = 0;         // 4  <- 0 if no further block
    
    var stringHash : UInt  = 0;         // 8  <- is only set in startblock otherwise 0

} // 16 ??

let xChar: Character = "X"

struct StringData : Init {
    var data = Array(count:32, repeatedValue:xChar)
}

//typealias StringBuffer = Character[32]

class StringStore<T> : DataStore<StringStoreHeader,StringData> {
    
    let BUFFER_LEN = 32;
    
    
    var unusedDataBlocks = NSMutableSet()
    var stringHashIndex = NSMutableDictionary()
    
    
    init(url: NSURL) {
        super.init(url: url)
        
        //self.dataSize = sizeof(StringStoreHeader) + BUFFER_LEN;
        
        if self.newFile {
            self.initStore()
        } else {
            self.readUnusedDataSegments()
        }
    }
    
    override func initStore() {
        // write block 0
        let text = "v1.0 String Store (c) S. Zehrer";
        var stringData = SOStringData(string: text)
        
        //self.createBlock(stringData, withID:0)
    }
    
    override func readUnusedDataSegments() {
        /**
        unsigned long long end = [self.fileHandle seekToEndOfFile];
        unsigned long long pos = [self calculatePos:[NSNumber numberWithID:1]];
        
        [self.fileHandle seekToFileOffset:pos];
        
        HEADER header;
        
        while (pos < end) {
            [self readHeader:&header];
            
            [self.fileHandle readDataOfLength:BUFFER_LEN];
            
            // read unusedDataBlock
            if (!header.isUsed) {
                [self.unusedDataBlocks addObject:[NSNumber numberWithLongLong:pos]];
            }
            
            // read stringHashIndex
            if (header.stringHash > 0) {
                NSNumber *index = [self calculateID:pos];
                NSNumber *hash = [NSNumber numberWithUnsignedLong:header.stringHash];
                [self.stringHashIndex setObject:index forKey:hash];
            }
            
            pos = self.fileHandle.offsetInFile;
        }
        */
    }
    



    
}