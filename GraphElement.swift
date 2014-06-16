//
//  GraphElement.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class GraphElement : NSObject, SOCoding {
    
    var id : NSNumber! = nil; // TODO migrate to UInt64!
    var isDirty: Bool = true  // TODO migrate to diry
    
    init() {
        
    }

    //#pragma mark - SOCoding
    
    init(data: NSData!) {
        
    }
        
    func encodeData() -> NSData! {
        return nil;
    }
    
    func update() {
        NSLog("ERROR: override this methode");
    }
    
}