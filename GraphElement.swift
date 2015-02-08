//
//  GraphElement.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 16.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


public class GraphElement {
    
    public var uid: UID? = nil
    public var dirty: Bool = true
    
    weak var context : GraphContext! = nil
  
    required public init() {
        
    }
    

/**

    //#pragma mark - SOCoding
    
    func update() {
        NSLog("ERROR: override this methode");
    }
    */
}