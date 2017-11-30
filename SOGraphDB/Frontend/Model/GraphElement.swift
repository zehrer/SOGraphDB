//
//  GraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class GraphElement : Identiy, Context {
    
    //Identiy
    public var uid: UID!
    
    public required init(uid aID: UID) {
        uid = aID
    }
    
    //Context
    public var context: SOGrapheDB!
    public var dirty: Bool = true
    
}
