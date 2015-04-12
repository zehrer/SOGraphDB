//
//  ObjectNSCodingStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol SOCoding : NSCoding {
    
    static func dataSize() -> Int
    
    var uid: UID! {get set} //identity
    var dirty: Bool {get set}
    
    init()
    
}

class ObjectBlock : NSObject, NSCoding {
    
    var used: Bool = true
    var obj: SOCoding? = nil
    
    override init() {
        super.init()
    }
    
    init(used: Bool) {
        super.init()
        self.used = used
    }
    
    init(obj:SOCoding) {
        super.init()
        self.obj = obj
    }

    //MARK: NSCoding
    
    @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
        
        used  = decoder.decodeBoolForKey("1")
        obj = (decoder.decodeObjectForKey("0") as! SOCoding)
    }
    
    @objc func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeBool(used, forKey:"1")
        
        if obj != nil {
            encoder.encodeObject(obj, forKey: "0")
        }
        
    }
    
}

public class ObjectStore<O: SOCoding> {
    
    //let headerSize = 10 //CONST manually updated
    //let dataSize = O.dataSize()
    let blockSize = 10 + O.dataSize()
    
    public var error: NSError?  // readonly?
    var errorOccurred = false
    
    var url: NSURL!
    var fileHandle: NSFileHandle!
    var newFile = false;
    
    var fileOffset : Int = 1  // see createNewFile
    
    var endOfFile: CUnsignedLongLong = 0;
    var unusedDataSegments =  Dictionary<CUnsignedLongLong,Bool>()
    
    let cache = NSCache()
    
    public init(url: NSURL) {
        
        self.url = url;
        
        if !url.isFileExisting() {
            
            if self.createNewFile() {
                newFile = true
            } else {
                errorOccurred = true
            }
            
            // TODO  add error handling
            // - out of memory
            // - no access
            
        }
        
        if !errorOccurred {
            self.fileHandle = NSFileHandle(forUpdatingURL: url, error: &self.error)
        }
        
        if self.fileHandle != nil {
            
            self.endOfFile = self.fileHandle.seekToEndOfFile()
            
            // central check of there store need an init
            // or a existing store need to read configuration
            if self.newFile {
                initStore()
            } else {
                readStoreConfiguration()
            }
            
        } else {
            errorOccurred = true
        }
    }
    
    deinit {
        if !errorOccurred {
            self.fileHandle.closeFile();
        }
    }
    
    // override in subclasses
    // - create a new file
    // - subclasses have to update fileOffset the default value is wrong
    func createNewFile() -> Bool {
        // update fileOffset
        
        let firstChar = "X"
        var data : NSData! = firstChar.dataUsingEncoding(NSUTF8StringEncoding)
        
        // TRUE if the operation succeeds, otherwise FALSE.
        return data.writeToURL(self.url, options: .DataWritingAtomic , error: &self.error)
    }
    
    // subclasses should overide this method
    // Create a block with the ID:0
    // ID 0 is not allowd to use in the store because
    func initStore() {
        
        registerBlock()
        
        // store SampleData as ID:0 in the file
        // ID:0 is a reserved ID and should not be availabled for public access
        let block = ObjectBlock(used: false)
        self.writeBlock(block)
        
        //var sampleData = O()
        //sampleData.uid = 0
        var emptyData = NSMutableData(length: O.dataSize())
        self.write(emptyData!)
    }
    
    // override in subclasses
    // This method is called only if the store is NOT new and no error is occurred
    // The intension is to scan an existing store and extract relevant data
    // - The default implementation call "readUnusedDataSegments" starting with block 1 (one)
    func readStoreConfiguration() {
        let pos = calculatePos(1)
        readUnusedDataSegments(pos)
    }
    
    // precondition: self.endOfFile is correct
    func readUnusedDataSegments(startPos: CUnsignedLongLong) {
        
        var pos = startPos
        
        self.fileHandle.seekToFileOffset(pos)
        
        while (pos < self.endOfFile) {
            // reade the complete file
            
            //var header = readHeader()
            
            let data = readBlock()
            let block = FastCoder.objectWithData(data) as! ObjectBlock
            
            let index = calculateID(pos)
            
            if block.used {
                // add pos into the special dictionary
                self.unusedDataSegments[pos] = true
            } else {
                analyseUsedBlock(block, forUID: index)
            }
            
            /**
            let data = self.fileHandle.readDataOfLength(dataSize)
            
            if block.used {
                analyseUsedData(data, forUID: index)
            }
            */
            
            pos = self.fileHandle.offsetInFile
        }
    }
    
    // subclasses could override this to further analyse header
    func analyseUsedBlock(block: ObjectBlock, forUID uid:UID) {
        
    }
    
    /**
    // subclasses could override this to further analyse data
    func analyseUsedData(data: NSData, forUID uid:UID) {
    }
    */
    
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
    
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: Objects
    //---------------------------------------------------------------------------------------------------------
    
    subscript(index: UID) -> O! {
        get {
            return self.readBlock(index)
        }
        
        set (newValue) {
            
            let pos = calculatePos(index)
            
            if (newValue != nil) {
                if (pos > endOfFile) {
                    // TODO: error
                } else {
                    writeBlock(newValue, atPos: pos)
                }
                
            } else {
                // newValue = nil -> delete
                deleteBlock(index)
            }
        }
    }
    
    public func registerObject(aObj: O) -> UID? {
        
        var result: UID? = nil
        
        if aObj.uid == nil {
            // only NEW object have a nil uid
            
            var pos  = self.registerBlock()
            result = self.calculateID(pos)
            aObj.uid = result
            
            self.cache.setObject(aObj, forKey: result!)
            
        }
        
        return result;
    }
    
    public func createObject() -> O {
        
        var result = O()
        
        addObject(result)
        
        return result
    }
    
    public func addObject(aObj: O) -> UID {
        
        var pos = registerBlock()
        var uid = calculateID(pos)
        
        self.writeBlock(aObj, atPos: pos)
        
        aObj.uid = uid
        aObj.dirty = false
        
        cache.setObject(aObj, forKey: uid)
        
        return uid
    }
    
    public func readObject(aID: UID) -> O! {
        
        var result :O! = cache.objectForKey(aID) as! O!
        
        if result == nil {
            // not in cache
            
            result = self[aID]  // read obj
            
            if (result != nil) {
                
                //result = O(data: data)
                //result.uid = aID
                
                //var key = NSNumber(long: uid)
                self.cache.setObject(result, forKey: aID)
            }
        }
        
        return result
    }
    
    public func updateObject(aObj: O) {
        
        if aObj.dirty && aObj.uid != nil {
            
            //TODO: write new implementation of updateObject
            //self[aObj.uid!] = aObj.data
            
            aObj.dirty = false
        }
    }
    
    public func deleteObject(aObj: O) {
        
        if aObj.uid != nil {
            cache.removeObjectForKey(aObj.uid!)
            self.deleteBlock(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: BLOCK
    //---------------------------------------------------------------------------------------------------------
    
    public func readBlock(index : UID) -> O! {
        
        self.seekToFileID(index)
        
        let data = readBlock()
        let block = FastCoder.objectWithData(data) as! ObjectBlock
        
        return block.obj as! O
    }
    
    func readBlock() -> NSData {
        return self.fileHandle.readDataOfLength(blockSize);
    }
    
    public func createBlock(data: O) -> UID {
        
        var pos = registerBlock()
        
        writeBlock(data, atPos: pos)
        
        return calculateID(pos)
    }
    
    func registerBlock() -> CUnsignedLongLong {
        
        var pos: CUnsignedLongLong? = nil
        let unusedBlocks = Array(unusedDataSegments.keys)
        
        if !unusedBlocks.isEmpty {
            pos = unusedBlocks[0]
        }
        
        if pos != nil {
            //self.unusedDataSegments removeObject:unusedSegmentPos];
            self.unusedDataSegments[pos!] = nil;
        } else {
            pos = self.extendFile()
        }
        
        return pos!;
    }
    
    func writeBlock(aObj: O, atPos pos: CUnsignedLongLong) {
        
        fileHandle.seekToFileOffset(pos)
        
        var block = ObjectBlock(obj: aObj)
        
        writeBlock(block)
    }
    
    func writeBlock(block: ObjectBlock) {
        
        let data = FastCoder.dataWithRootObject(block)
        write(data)
    }
    
    // subclases have to override
    func deleteBlock(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        var block = ObjectBlock(used: false)
        
        writeBlock(block)
        
        self.unusedDataSegments[pos] = true
        
        return pos
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: HEADER
    //---------------------------------------------------------------------------------------------------------
    
    /**
    
    func readHeader() -> ObjectBlock<O> {
        var headerData = self.fileHandle.readDataOfLength(headerSize);
        
        return FastCoder.objectWithData(headerData) as ObjectBlock
    }

    // Default code
    // subclass should override this methode
    func writeHeader(forData data: O, atPos pos:CUnsignedLongLong) {
        
        var header = ObjectBlock<O>()
        header.used = true
        
        writeHeader(header)
    }
    
    func writeHeader(header: ObjectBlock<O>) {
        
        let data = FastCoder.dataWithRootObject(header)
        
        write(data)
    }
    */

    //---------------------------------------------------------------------------------------------------------
    //MARK: DATA
    //---------------------------------------------------------------------------------------------------------
    
    /**
    
    func readData() -> O {
        
        var objectData = self.fileHandle.readDataOfLength(dataSize);
        
        return FastCoder.objectWithData(objectData) as O
    }
    
    // subclass should override this methode
    func writeData(data: O) {
        
        var buffer = FastCoder.dataWithRootObject(data)
        
        write(buffer)
    }

    */

    
    //---------------------------------------------------------------------------------------------------------
    // MARK: GENERAL NSDATA
    //---------------------------------------------------------------------------------------------------------
    
    // used to write header and data
    func write(data: NSData) {
        self.fileHandle.writeData(data);
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: Cache Controll
    //---------------------------------------------------------------------------------------------------------
    
    public func removeAllObjectsForCache() {
        cache.removeAllObjects()
    }

}
