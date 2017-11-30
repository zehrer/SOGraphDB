//
//  Node.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 17.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class Node : PropertyAccessElement { //Equatable 

    public override init() {
        super.init()
    }
    
    public required init(uid aID: UID) {
        super.init(uid: aID)
    }
    
}
