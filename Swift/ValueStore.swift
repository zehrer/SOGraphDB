//
//  ValueStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 23.06.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public typealias UID = Int // UInt32 don't save to much memory at the moment

public protocol Identiy {
    
    var uid: UID? {set get} //identity
    
    init (uid aID : UID)
}

/**
extension Identiy {
    
    // MARK: Hashable
    
    public var hashValue: Int {
        get {
            if uid != nil {
                return uid!.hashValue
            }
            return 0
        }
    }
}


extension Identiy {
    public init (uid aID : UID) {
        uid = aID
    }
}
*/

// TODO: test without codeing
public protocol SizeTest : Coding {
    
    static func generateSizeTestInstance() -> Self
    
}

extension SizeTest {
    static func calculateDataSize(_ encoder : SOEncoder) -> Int {
        
        let value = generateSizeTestInstance()
        encoder.reset()
        encoder.encode(value)
        
        return encoder.length
    }
}

public protocol ValueStoreElement : Identiy, SizeTest {
    
    //var dirty: Bool {get set}
    
}

open class ValueStore<V: ValueStoreElement> {
    
    var url: URL
    var fileHandle: FileHandle
    var newFile = false
    
    let fileOffset = 1  // see createNewFile
    var endOfFile : CUnsignedLongLong = 0
    
    var encoder : SOEncoder
    var decoder = SODecoder()
    
    // UInt8 = size of type of boolean (used flag)
    let blockSize : Int
    
    // this set contails a collection of block POS in the file which are not used
    var unusedDataSegments = Set<CUnsignedLongLong>()
    
    // Throws
    public init(url aURL: URL) throws {
        
        self.url = aURL;
        
        let encoder = SOEncoder()
        self.encoder = encoder
        
        let dataSize =  V.calculateDataSize(encoder)
        self.blockSize = MemoryLayout<UInt8>.size + dataSize
        
        if !url.isFileExisting() {
            // file does NOT exist
            do {
                let data = ValueStore.createFileHeader()
                try data.write(to: self.url, options: NSData.WritingOptions.atomic)
                self.newFile = true
            } catch {
                fileHandle = FileHandle.nullDevice
                throw error
            }
        }
        
        do {
             self.fileHandle = try FileHandle(forUpdating: url)
        } catch {
            fileHandle = FileHandle.nullDevice
            throw error
        }
        
        self.endOfFile = self.fileHandle.seekToEndOfFile()
        
        // central check of there store need an init
        // or a existing store need to read configuration
        if newFile {
            initStore()
        } else {
            readStoreConfiguration()
        }
        
        
    }
    
    // possible to override in subclasses
    // - create a new file
    // - update fileOffset the default value is wrong
    class func createFileHeader() -> Data {
        
        let firstChar = "X"
        // tested code
        return firstChar.data(using: String.Encoding.utf8)!

    }
    
    // subclasses should overide this method
    // Create a block with the ID:0
    // ID 0 is not allowd to use in the store because
    open func initStore() {
        
        //registerBlock()
        
        // store SampleData as ID:0 in the file
        // ID:0 is a reserved ID and should not be availabled for public access
        //let block = Block(used: false)
        //self.writeBlock(block)
        
        //var sampleData = O()
        //sampleData.uid = 0
        //let emptyData = NSMutableData(length: V.dataSize())
        //self.write(emptyData!)
    }
    
    // precondition: self.endOfFile is correct
    func readStoreConfiguration() {
        
        var pos = calculatePos(1)
        
        self.fileHandle.seek(toFileOffset: pos)
        
        while (pos < self.endOfFile) {
            // reade the complete file
            
            //var header = readHeader()
            
            let data = readBlockData()

            decoder.resetData(data)
            let used : Bool = decoder.decode()

            //let index = calculateID(pos)
            
            if used {
                //analyseUsedBlock(block!, forUID: index)
            } else {
                // add pos into the special dictionary
                unusedDataSegments.insert(pos)
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
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: Value
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
    
    open func registerValue() -> UID {
        
        let pos  = self.registerBlock()
        return self.calculateID(pos)

    }
    
    open func createValue() -> V {
        
        let uid = registerValue()
        
        let result = V(uid: uid)
        
        return result
    }
    
    /**
    public func addValue(value: V) -> UID {
        
        let pos = registerBlock()
        let uid = calculateID(pos)
        
        self.writeBlock(aObj, atPos: pos)
        
        value.uid = uid
        value.dirty = false
        
        //cache.setObject(aObj, forKey: uid)
        
        return uid
    }*/
    
    open func readValue(_ index : UID) -> V? {
        
        self.seekToFileID(index)
        
        let data = readBlockData()
        
        if data.count > 0 {
            
            decoder.resetData(data)
            let used : Bool = decoder.decode()
            
            if used {
                let result : V? = decoder.decode()
                if var result = result {
                    result.uid = index
                }
                
                return result
            }
        }
        
        return nil
    }
    
    open func updateValue(_ value: V) {
        
        if value.uid != nil {
            let pos = calculatePos(value.uid!)
            writeBlock(value, atPos: pos)
        } else {
            assertionFailure("ID is missing")
        }
    }
    
    open func delete(_ value : V) {
    
        if value.uid != nil {
            deleteBlock(value.uid!)
            //aObj.uid = nil;
        } else {
            assertionFailure("ID is missing")
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: BLOCK
    //---------------------------------------------------------------------------------------------------------
    
    func readBlockData() -> Data {
        return self.fileHandle.readData(ofLength: blockSize);
    }

    func registerBlock() -> CUnsignedLongLong {
        
        var pos: CUnsignedLongLong? = nil
        
        if !unusedDataSegments.isEmpty {
            pos = unusedDataSegments.first
        }
        
        if pos != nil {
             unusedDataSegments.remove(pos!)
        } else {
            pos = self.extendFile()
        }
        
        return pos!;
    }
    
    func writeBlock(_ value: V, atPos pos: CUnsignedLongLong) {
        
        fileHandle.seek(toFileOffset: pos)
        
        encodeHeader(true)
        encoder.encode(value)
        
        if encoder.length > blockSize {
            assertionFailure("ERROR: blocksize is to small")
        }

        write(encoder.output as Data)
    }
    
    func deleteBlock(_ aID: UID) -> CUnsignedLongLong {
        
        let pos = self.seekToFileID(aID)
        
        encodeHeader(false)
        
        write(encoder.output as Data)
        
        self.unusedDataSegments.remove(pos)
        
        return pos
    }
    
    func encodeHeader(_ used : Bool) {
        encoder.reset()
        encoder.encode(used)
    }
    
     /**
    
    public func createBlock(data: O) -> UID {
    
    let pos = registerBlock()
    
    writeBlock(data, atPos: pos)
    
    return calculateID(pos)
    }
    
    func writeBlock(aObj: O, atPos pos: CUnsignedLongLong) {
        
        fileHandle.seekToFileOffset(pos)
        
        let block = Block(obj: aObj)
        
        writeBlock(block)
    }

   
    func writeBlock(block: Block) {
        
        let data = FastCoder.dataWithRootObject(block)
        if data != nil {
            
            if data!.length > blockSize {
                assertionFailure("ERROR: blocksize is to small")
            }
            
            write(data!)
        } else {
            assertionFailure("NSData is nil")
        }
        
    }
    */
    
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: File Methode
    //---------------------------------------------------------------------------------------------------------


    // #pragma mark - register and endofFile

    // used to write header and data
    func write(_ data: Data) {
        self.fileHandle.write(data);
    }
    
    func seekEndOfFile() -> CUnsignedLongLong {
        return self.fileHandle.seekToEndOfFile()
    }
    
    
    // increase the virtual EndOfFile pointer by on dataSize
    func extendFile() -> CUnsignedLongLong {
        
        let pos = self.endOfFile
        
        self.endOfFile += CUnsignedLongLong(blockSize)
        
        return pos;
    }
    
    
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

}
