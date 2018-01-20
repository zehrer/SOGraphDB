//
//  GXL.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 20.01.18.
//

import Foundation

struct GLX {
    struct Elements {
        static let glx = "glx"
        static let graph = "graph"
        static let node = "node"
        static let relationship = "edge"
        static let property = "attr"
    }
    
    struct Attributes {
        static let id = "id"
        static let relStart = "from"
        static let relEnd = "to"
        
        static let key = "key"  //Property
    }

    struct Property {
        static let string = "string"
        static let int = "int"
        static let bool = "bool"
    }

}
