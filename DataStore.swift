//
//  DataStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 17.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

// #pragma mark -

// Concept requirements & implementation

// A block contains a header and data

// CRUD D
// - generic data
// - generic header
// - read / write header

// required "endOfFile" marker
// required "unusedDataSegments"
// register fuction


// UID = 0 is not allowed to use !!

// H = a header
// D = a data 


// TODO: The term store here is not 100% presice 

public class DataStore<H: DataStoreHeader,D: Init>  {
    
    // #pragma mark ----------------------------------------------------------------
    
    // data.length + header.length;
    let headerSize = sizeof(H)
    let dataSize = sizeof(D)
    let blockSize = sizeof(H) + sizeof(D)  // test as CUnsignedLongLong
    
    public var error: NSError?  // readonly?
    
    var url: NSURL!
    var fileHandle: NSFileHandle!
    var newFile = false;
    
    var fileOffset : Int = 1  // see createNewFile
    
    var endOfFile: CUnsignedLongLong = 0;
    var unusedDataSegments =  Dictionary<CUnsignedLongLong,Bool>()
    
    // #pragma mark ----------------------------------------------------------------
    
    public init(url: NSURL) {
        
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
        self.endOfFile = self.fileHandle.seekToEndOfFile()
        
        // central check of there store need an init
        // or a existing store need to read configuration
        if self.newFile {
            initStore()
        } else {
            readStoreConfiguration()
        }
    }
    
    deinit {
        self.fileHandle.closeFile();
    }
    
    // override in subclasses
    // - create a new file 
    // - subclasses have to update fileOffset the default value is wrong
    func createNewFile() -> Bool {
        // update fileOffset
        
        let firstChar = "X"
        var data : NSData! = firstChar.dataUsingEncoding(NSUTF8StringEncoding)
        
        return data.writeToURL(self.url, atomically: true)
    }
    
    // override in subclasses
    // This method is called only if the file is new
    // The intension is to write the datablock number 0
    func initStore() {
        
        registerBlock()
        
        // write header
        var header = H()
        header.used = false
        self.writeHeader(header)
        
        // write data
        let sampleData = D()
        self.writeData(sampleData)
    }

    // override in subclasses
    // This method is called only if the store is NOT new
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
            
            var optinalHeader : H! = readHeader()
            
            if var header = optinalHeader {
                
                let index = calculateID(pos)
                
                if !header.used {
                    // add pos into the special dictionary
                    self.unusedDataSegments[pos] = true
                } else {
                    analyseUsedHeader(&header, forUID: index)
                }
                
                let data = self.fileHandle.readDataOfLength(dataSize)
                
                if header.used {
                    analyseUsedData(data, forUID: index)
                }
                
            } else {
                // TODO error handling
                // why is header here nil?
                // should never happen
            }
            
            pos = self.fileHandle.offsetInFile
        }
    }
    
    // subclasses could override this to further analyse header
    func analyseUsedHeader(inout header: H, forUID uid:UID) {
        
    }
    
    // subclasses could override this to further analyse data
    func analyseUsedData(data: NSData, forUID uid:UID) {
    }
    
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
    
    // basic block methodes
    subscript(index: UID) -> D! {
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
    
    // #pragma mark READ -------------------------------------------------------
    

    public func readBlock(index : UID) -> D! {
        self.seekToFileID(index)
        
        let header :H! = readHeader()
        
        if (header.used) {
            return self.readData()
        }
        
        return nil;
    }
    
    // #pragma mark - read/write header
    
    // TODO: similar code for read data and read header (no added value)
    
    func readHeader() -> H! {
        
        let data : NSData! = readHeader()
        
        if (data != nil) {
            
            var result : H! = nil
            
            // TODO: how to read data from NSData to a value variable?
            data.getBytes(&result)
            
            return result
        }
        
        return nil;
    }
    
    func readHeader() -> NSData {
        return self.fileHandle.readDataOfLength(sizeof(H));
    }
    
    func readData() -> D! {
        
        var data : NSData! = readData()
        
        if (data != nil) {
            var result : D! = nil
            
            data.getBytes(&result)
            
            return result
        }
        
        return nil;
    }
    
    func readData() -> NSData {
        return self.fileHandle.readDataOfLength(sizeof(D));
    }
    
    func read<T>() -> T! {
        let data : NSData! = self.fileHandle.readDataOfLength(sizeof(T));
        
        if data != nil {
            
            var result : T! = nil
            
            data.getBytes(&result, length: sizeof(T))
            
            return result
        }
        
        return nil
    }
    
    // #pragma mark WRITE -------------------------------------------------------
    
    public func createBlock(data: D) -> UID {
        
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
    
    func writeBlock(data: D, atPos pos: CUnsignedLongLong) {
        
        fileHandle.seekToFileOffset(pos)
        writeHeader(forData: data, atPos: pos)
        writeData(data)
    }
    
    // Default code
    // subclass should override this methode
    func writeHeader(forData data:D, atPos pos:CUnsignedLongLong) {
        
        var header = H()
        header.used = true
        
        writeHeader(header)
    }
    
    func writeHeader(header: H) {
        
        var a = header
        
        let headerData = NSData(bytesNoCopy:&a, length:sizeof(H), freeWhenDone:false)
    
        write(headerData)
    }
    

    
    // subclass should override this methode
    func writeData(data: D) {
        // TODO: FIX
        var a = data
        let buffer = NSData(bytesNoCopy:&a, length:sizeof(D), freeWhenDone:false)
        
        write(buffer)
    }
    

    // used to write header and data
    func write(data: NSData) {
        self.fileHandle.writeData(data);
    }
    
    
    // #pragma mark DELETE -------------------------------------------------------

    
    // subclases have to override
    func deleteBlock(aID: UID) -> CUnsignedLongLong {
        
        var pos = self.seekToFileID(aID)
        
        var header = H()
        header.used = false
        
        self.writeHeader(header)
        
        self.unusedDataSegments[pos] = true
        
        return pos
    }

    
    
    // #pragma mark READ -------------------------------------------------------
    
    // #pragma mark WRITE -------------------------------------------------------
    
    // #pragma mark DELETE -------------------------------------------------------

    
}