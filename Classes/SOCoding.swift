//
//  SOCoding.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 07.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

// NOT USED AT THE MOMENT

import Foundation

@objc protocol SOCoding {
    
    var id: NSNumver
    var isDirty: Bool
    
    @required
    
    init(data: NSData)
    
    func encodeData() -> NSData
    
    @optional
    
    func decodeData(fileHandler: NSFileHandle)
    
}


/**
// define the possition of the node in the node store
// return nil of not in the store
// don't set this @property, it is manged by the store
@property (nonatomic) NSNumber *id;

// mark if the was updated on disk.
@property (nonatomic) BOOL isDirty;

@required

- (instancetype)initWithData:(NSData *)data;

- (NSData *)encodeData;

@optional

- (void)decodeData:(NSFileHandle *)fileHandle;

*/