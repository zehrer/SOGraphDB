//
//  PropertyGraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class PropertyGraphElement : GraphElement, PropertyAccess {

    public var uid: UID!
    
    public var propertiesDictionary: [UID : Property] = [:]
    
}
