//
//  GraphElement.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class GraphElement {
    
    var uid: UID? = nil
    var dirty: Bool = true
    
    weak var context : GraphContext! = nil
  
    required init() {
        
    }
    

/**

    //#pragma mark - SOCoding
    
    func encodeData() -> NSData! {
        return nil;
    }
    
    func update() {
        NSLog("ERROR: override this methode");
    }
    */
}