//
//  ObjectNSCodingStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.04.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol ObjectStoreElement : class {
    
    static func dataSize() -> Int
    
    var uid: UID? {get set} //identity
    var dirty: Bool {get set}
    
    init()
    
}

// Accoriding related unit test the size of this class is 13 Bytes with the short ObjC name
@objc(block)
internal class Block : NSObject, NSCoding {
    
    var used: Bool = true
    var obj: ObjectStoreElement? = nil
    
    override init() {
        super.init()
    }
    
    init(used: Bool) {
        super.init()
        self.used = used
    }
    
    init(obj:ObjectStoreElement) {
        super.init()
        self.obj = obj
    }
    
    //MARK: NSCoding
    
    @objc required init(coder decoder: NSCoder) { // NS_DESIGNATED_INITIALIZER
        super.init()
        
        used  = decoder.decodeBool(forKey: "A")
        if used {
            obj = decoder.decodeObject(forKey: "B") as? ObjectStoreElement
        }
    }
    
    @objc func encode(with encoder: NSCoder) {
        encoder.encode(used, forKey:"A")
        
        if used && obj != nil {
            if let obj = obj! as? NSCoding {
                encoder.encode(obj, forKey: "B")
            } else {
                assertionFailure("The related store element don't implement NSCoding")
            }
        }
        
    }
    
}


open class ObjectStore<O: ObjectStoreElement> {
    


    // TODO: improve blocksize detection
    let blockSize = 13 + O.dataSize()
    
    open var error: NSError?  // readonly?
    var errorOccurred = false
    
    var url: URL!
    var fileHandle: FileHandle!
    var newFile = false;
    
    var fileOffset : Int = 1  // see createNewFile
    
    var endOfFile: CUnsignedLongLong = 0;
    var unusedDataSegments =  Dictionary<CUnsignedLongLong,Bool>()
    
    let cache = NSCache<AnyObject, AnyObject>()
    
    public init(url aURL: URL) {
        
        url = aURL;
        
        if !url.isFileExisting() {
            
            if createNewFile() {
                newFile = true
            } else {
                errorOccurred = true
            }
            
            // TODO  add error handling
            // - out of memory
            // - no access
            
        }
        
        if !errorOccurred {
            // TODO ERROR Handling
            fileHandle = try! FileHandle(forUpdating: url)
        }
        
        if fileHandle != nil {
            
            endOfFile = self.fileHandle.seekToEndOfFile()
            
            // central check of there store need an init
            // or a existing store need to read configuration
            if newFile {
                initStore()
            } else {
                readStoreConfiguration()
            }
            
        } else {
            errorOccurred = true
        }
    }
    
    deinit {
        if fileHandle != nil {
            self.fileHandle.closeFile();
        }
    }
    
    // override in subclasses
    // - create a new file
    // - subclasses have to update fileOffset the default value is wrong
    func createNewFile() -> Bool {
        // update fileOffset
        
        let firstChar = "X"
        let data : Data! = firstChar.data(using: String.Encoding.utf8)
        
        // TRUE if the operation succeeds, otherwise FALSE.
        // TODO ERROR HANDLING
        do {
            try data.write(to: self.url, options: NSData.WritingOptions.atomic)
        } catch {
            return false
        }
        
        return true
    }
    
    // subclasses should overide this method
    // Create a block with the ID:0
    // ID 0 is not allowd to use in the store because
    func initStore() {
        
        var pos = registerBlock()
        
        // store SampleData as ID:0 in the file
        // ID:0 is a reserved ID and should not be availabled for public access
        let block = Block(used: false)
        self.writeBlock(block)
        
        //var sampleData = O()
        //sampleData.uid = 0
        let emptyData = NSMutableData(length: O.dataSize())
        self.write(emptyData! as Data)
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
    func readUnusedDataSegments(_ startPos: CUnsignedLongLong) {
        
        var pos = startPos
        
        self.fileHandle.seek(toFileOffset: pos)
        
        while (pos < self.endOfFile) {
            // reade the complete file
            
            //var header = readHeader()
            
            let data = readBlock()
            let block = FastCoder.objectWithData(data) as! Block?
            
            let index = calculateID(pos)
            
            if block != nil {
                if block!.used {
                    analyseUsedBlock(block!, forUID: index)
                } else {
                    // add pos into the special dictionary
                    self.unusedDataSegments[pos] = true
                    // TODO: use new set now?
                }
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
    func analyseUsedBlock(_ block: Block, forUID uid:UID) {
        
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
    
    //MARK: -  pos Calcuation
    
    func calculatePos(_ aID: UID) -> CUnsignedLongLong {
        
        return CUnsignedLongLong((aID * self.blockSize) + self.fileOffset)
        
    }
    
    func calculateID(_ pos: CUnsignedLongLong) -> UID {
        
        let result = (Int(pos) - self.fileOffset) / self.blockSize;
        
        return result
    }
    
    func seekToFileID(_ aID: UID) -> CUnsignedLongLong {
        
        let pos = self.calculatePos(aID)
        
        self.fileHandle.seek(toFileOffset: pos)
        
        return pos
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: Objects
    //---------------------------------------------------------------------------------------------------------
    
    /**
    subscript(index: UID) -> O! {
        get {
            return self.readObject(index)
        }
        
        set {
            
            let pos = calculatePos(index)
            
            if (newValue != nil) {
                // TODO: Check index and object UID
                updateObject(newValue)
            } else {
                // newValue = nil -> delete
                deleteObject(index)
            }
        }
    }
*/
    
    open func registerObject(_ aObj: O) -> UID? {
        
        var result: UID? = nil
        
        if aObj.uid == nil {
            // only NEW object have a nil uid
            
            let pos  = self.registerBlock()
            result = self.calculateID(pos)
            aObj.uid = result
            
            self.cache.setObject(aObj, forKey: result! as AnyObject)
            
        }
        
        return result;
    }
    
    open func createObject() -> O {
        
        let result = O()
        
        addObject(result)
        
        return result
    }
    
    open func addObject(_ aObj: O) -> UID {
        
        let pos = registerBlock()
        let uid = calculateID(pos)
        
        self.writeBlock(aObj, atPos: pos)
        
        aObj.uid = uid
        aObj.dirty = false
        
        cache.setObject(aObj, forKey: uid as AnyObject)
        
        return uid
    }
    
    open func readObject(_ index: UID) -> O! {
        
        var result :O! = cache.object(forKey: index as AnyObject) as! O!
        
        if result == nil {
            // not in cache
            
            result = readBlock(index)
            
            if (result != nil) {
                result.uid = index
                self.cache.setObject(result, forKey: index as AnyObject)
            }
        }
        
        return result
    }
    
    open func updateObject(_ aObj: O) {
        
        if aObj.dirty && aObj.uid != nil {
            
            let pos = calculatePos(aObj.uid!)
            
            writeBlock(aObj, atPos: pos)
            
            aObj.dirty = false
        }
    }
    
    open func deleteObject(_ aObj: O) {
        
        if aObj.uid != nil {
            deleteObject(aObj.uid!)
            aObj.uid = nil;
        }
    }
    
    func deleteObject(_ index : UID) {
        cache.removeObject(forKey: index as AnyObject)
        self.deleteBlock(index)
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: BLOCK
    //---------------------------------------------------------------------------------------------------------
    
    open func readBlock(_ index : UID) -> O! {
        
        self.seekToFileID(index)
        
        let data = readBlock()
        
        if data.count > 0 {
            let block = FastCoder.objectWithData(data) as! Block?
            if block != nil {
               return block!.obj as? O
            }
        }
        
        return nil
    }
    
    func readBlock() -> Data {
        return self.fileHandle.readData(ofLength: blockSize);
    }
    
    open func createBlock(_ data: O) -> UID {
        
        let pos = registerBlock()
        
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
    
    func writeBlock(_ aObj: O, atPos pos: CUnsignedLongLong) {
        
        fileHandle.seek(toFileOffset: pos)
        
        let block = Block(obj: aObj)
        
        writeBlock(block)
    }
    
    func writeBlock(_ block: Block) {
        
        let data = FastCoder.dataWithRootObject(block)
        if data != nil {
            
            if data!.count > blockSize {
               assertionFailure("ERROR: blocksize is to small")
            }
            
            write(data!)
        } else {
            assertionFailure("NSData is nil")
        }
        
    }
    
    func deleteBlock(_ aID: UID) -> CUnsignedLongLong {
        
        let pos = self.seekToFileID(aID)
        
        let block = Block(used: false)
        
        writeBlock(block)
        
        self.unusedDataSegments[pos] = true
        
        return pos
    }
    
    //---------------------------------------------------------------------------------------------------------
    // MARK: GENERAL NSDATA
    //---------------------------------------------------------------------------------------------------------
    
    // used to write header and data
    func write(_ data: Data) {
        self.fileHandle.write(data);
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: Cache Controll
    //---------------------------------------------------------------------------------------------------------
    
    open func removeAllObjectsForCache() {
        cache.removeAllObjects()
    }

}
