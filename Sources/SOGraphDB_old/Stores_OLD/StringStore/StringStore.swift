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
    
    required init() {
        stringData = NSMutableData()
        encoding = NSUTF8StringEncoding
        hash = 0
    }
    
    init(string: String) {
        
        let dataUTF8 : NSData! = string.dataUsingEncoding(NSUTF8StringEncoding)
        let dataUTF16 : NSData! = string.dataUsingEncoding(NSUTF16StringEncoding)
        
        //let test = string.cStringUsingEncoding(NSUTF8StringEncoding)
        
        if dataUTF8.length <= dataUTF16.length {
                stringData = dataUTF8
                encoding = NSUTF8StringEncoding
        } else {
                stringData = dataUTF16
                encoding = NSUTF16StringEncoding
        }
        
        hash = UInt64(stringData.crc32Hash())

    }
    
    var length : UInt {
        get {
            return UInt(stringData.length)
        }
    }
    
    class func decode(data: NSData, encodingUTF8: Bool) -> String {
        if encodingUTF8 {
            return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        } else {
            return NSString(data: data, encoding:NSUnicodeStringEncoding)! as String
        }
        //TODO: test optional Strings
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
    
    required init() {
        
    }

} // 16 ??

// Classes derived from generic classes must also be generic. But why?

typealias StringStore = AStringStore<StringData>

class AStringStore<T: Init> : DataStore<StringStoreHeader,T> {
    
    let BUFFER_LEN : UInt = 32
    
    // TODO: Use Swift Dictinary
    //var stringHashIndex = NSMutableDictionary()
    var stringHashIndex = Dictionary<UInt64,UID>()
    
    
    override init(url: NSURL) {
        super.init(url: url)
        
        //self.dataSize = sizeof(StringStoreHeader) + BUFFER_LEN;
    }
    
    override func initStore() {
        // write block 0
        //let text = "v1.0 String Store (c) S. Zehrer";
        //var stringData = SOStringData(string: text)
        
        //self.createBlock(stringData, withID:0)
    }

    override func analyseUsedHeader(inout header: StringStoreHeader, forUID uid: UID) {

        if header.stringHash > 0 {
            //self.stringHashIndex.setObject(uid, forKey: header.stringHash)
            stringHashIndex[header.stringHash] = uid
        }
        
        // stringHash = 0 means this is not the first block
    }
    
    subscript(text: String) -> UID! {
        get {
            let data = StringData(string: text)
            
            var uid = stringHashIndex[data.hash]
            
            if uid == nil {
                // string seems not in the store
                uid = self.createBlocks(data)
                
                stringHashIndex[data.hash] = uid
            }
            
            return uid
        }
    }
    
    subscript(index: UID) -> String! {
        get {
            return readBlocks(index)
        }
    }
    
    
    // #pragma mark READ -------------------------------------------------------

    func readBlocks(index: UID, aData: NSMutableData! = nil) -> String! {
        
        var result : String! = nil
        var data = aData
        
        self.seekToFileID(index)
        let header : StringStoreHeader = readHeader()
        
        if header.used {
            if aData == nil {
                // seems we read the frist block
                data = NSMutableData()
            }
            
            data.appendData(readData())
            
            if header.nextStringID > 0 {
                readBlocks(header.nextStringID,aData: data)
            }
            
            if aData == nil {
                // seems we read the frist block
                result = SOStringData.decodeData(data, withUTF8: header.encodingUTF8)
            }
        
        }
        
        return result;
    }
    
    override func readData() -> NSData {
        return self.fileHandle.readDataOfLength(Int(BUFFER_LEN));
    }
    
    // #pragma mark WRITE -------------------------------------------------------
    
    // return the uid of the firstBlock
    func createBlocks(stringData: StringData) -> UID {
        
        var result : UID = 0
        
        if stringData.length > BUFFER_LEN {
            // TODO: split data
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
        
        let pos = registerBlock()
        
        let header = StringStoreHeader()
        header.stringHash = stringData.hash
        header.nextStringID = nextStringID
        header.encodingUTF8 = stringData.encoding == NSUTF8StringEncoding
        
        header.used = true
        header.bufferLength = UInt8(stringData.length)
        
        let data : NSData = stringData.stringData.extendSize(BUFFER_LEN)
        
        writeHeader(header)
        write(data);
        
        return calculateID(pos)
    }
    
    // #pragma mark DELETE -------------------------------------------------------

    
    override func deleteBlock(uid: UID) -> CUnsignedLongLong {
        
        let pos = self.seekToFileID(uid)
        
        let header : StringStoreHeader = readHeader()
        
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