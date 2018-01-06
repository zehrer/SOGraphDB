//
//  GraphElement.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class GraphElement : GraphStore {
  
    //Context
    public var graphStore: SOGraphDBStore!
    public var dirty: Bool = true
    
    // General
    
    public init() {
    }
    
    // The whole type system is under developent 
    // shall it implement a single type system (each element can have just one type)
    // or compatible to rdf, each node can have several types
    public var type : Node?  ///(similar to rdf:type)
    
    // is true only if there is a direct or indirect relationship to the basic class node
    //
    var isClass : Bool = false

    //public var 
    
}
