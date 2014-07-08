//
//  StringStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 29.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class StringData : Init {
    
    let stringData : NSData
    let encoding : NSStringEncoding
    let hash : UInt64
    
    init() {
        stringData = NSMutableData()
        encoding = NSUTF8StringEncoding
        hash = 0
    }
    
    init(string: String) {
        let dataUTF8 = string.dataUsingEncoding(NSUTF8StringEncoding)
        let dataUTF16 = string.dataUsingEncoding(NSUTF16StringEncoding)
        
        let test = string.cStringUsingEncoding(NSUTF8StringEncoding)
        
        if dataUTF8.length <= dataUTF16.length {
                stringData = dataUTF8
                encoding = NSUTF8StringEncoding
        } else {
                stringData = dataUTF16
                encoding = NSUTF16StringEncoding
        }
        
        hash = UInt64(stringData.crc32Hash())

    }
    
    var length : Int {
        get {
            return stringData.length
        }
    }
    
    //CC_MD5_DIGEST_LENGTH
}

/**

let xChar: Character = "X"
struct StringData : Init {
    var data = Array(count:32, repeatedValue:xChar)
}

typealias StringBuffer = Character[32]
*/

class StringStoreHeader : DataStoreHeader {
    
    var used: Bool = true;            // 1
    var encodingUTF8 : Bool = true;    // 1  <- yes string usues UTF8 / NO == UTF16
    
    var bufferLength : UInt8 = 0;       // 1Byte
    var nextStringID : UID = 0;         // 4  <- 0 if no further block
    
    var stringHash : UInt64  = 0;         // 8  <- is only set in startblock otherwise 0

} // 16 ??


class StringStore<T> : DataStore<StringStoreHeader,StringData> {
    
    let BUFFER_LEN = 32
    
    // TODO: Use Swift Dictinary
    //var stringHashIndex = NSMutableDictionary()
    var stringHashIndex = Dictionary<UInt64,UID>()
    
    
    init(url: NSURL) {
        super.init(url: url)
        
        //self.dataSize = sizeof(StringStoreHeader) + BUFFER_LEN;
    }
    
    override func initStore() {
        
        if self.newFile {
            // write block 0
            let text = "v1.0 String Store (c) S. Zehrer";
            var stringData = SOStringData(string: text)
            
            //self.createBlock(stringData, withID:0)
        } else {
            var startPos = self.calculatePos(1)
            self.readUnusedDataSegments(startPos)
        }
    }

    override func analyseUsedHeader(inout header: StringStoreHeader, forUID uid: UID) {

        if header.stringHash > 0 {
            //self.stringHashIndex.setObject(uid, forKey: header.stringHash)
            stringHashIndex[header.stringHash] = uid
        } else {
            // error 
            //seems no hash for a used block
            NSLog("Error: Block ID:\(uid) has a zero hash")
        }
        
    }
    
    // #pragma mark - CRUD Data
    
    // return the uid of the firstBlock
    func createBlocks(stringData: StringData) -> UID {
        
        var result : UID = 0
        
        if stringData.length > BUFFER_LEN {
            // TODO: split !
        } else {
            result = createBlock(stringData, withNextID: 0)
        }
        
        return result
    }
    

    /**
    * The following pre-conditions are relevant:
    * - stringData is mandatory
    * - stringHash is optional -> otherwise 0;
    * - nextID is optional -> otherwise 0;
    *
    * Possible options
    * - First Block
    *   -> stringHash is mandatory
    *   -> nextID is the reference to the next block or 0 for the end
    
    * - Further Block
    *   -> stringHash is 0
    *   -> nextID is the refernece to the next block or 0 for the end
    */
    func createBlock(stringData: StringData, withNextID nextStringID:UID) -> UID {
        
        var pos = registerBlock()
        
        var header = StringStoreHeader()
        header.stringHash = stringData.hash
        header.nextStringID = nextStringID
        header.encodingUTF8 = stringData.encoding == NSUTF8StringEncoding
        
        header.used = true
        header.bufferLength = UInt8(stringData.length)
        
        var data : NSData = stringData.stringData.extendSize(BUFFER_LEN)
        
        writeHeader(header)
        write(data);
        
        return calculateID(pos)
    }
    
    // #pragma mark ----------------------------------------------------------------
    

    subscript(text: String) -> UID! {
        get {
            let data = StringData(string: text)
            
            var uid = stringHashIndex[data.hash]
            
            if !uid {
                // string seems not in the store
                uid = self.createBlocks(data)
                
                stringHashIndex[data.hash] = uid
            }
            
            return uid
        }
    }
    
    /**
    subscript(index: UID) -> String {
        get {
            var data : StringData = self[index]
        }
    }
    */
    /**
    [self seekToFileID:aIndex];
    
    HEADER header;
    [self readHeader:&header];
    
    NSString *result = nil;
    
    if (header.isUsed) {
    NSData *data = [self readData:header.bufferLength];
    result = [SOStringData decodeData:data withUTF8:header.isUTF8Encoding];
    }
    
    return result
*/
    
    // #pragma mark DELETE -------------------------------------------------------

    
    override func deleteBlock(uid: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(uid)
        
        var header : StringStoreHeader = readHeader()
        
        if header.nextStringID > 0 {
            deleteBlock(header.nextStringID)
        }
        
        header.used = false
        //header.stringHash = 0
        header.nextStringID = 0
        
        writeHeader(header)
        
        return pos
    }
    
}