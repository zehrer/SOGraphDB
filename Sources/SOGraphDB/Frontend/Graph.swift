//
//  Graph.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 21.01.18.
//

import Foundation

public class Graph : PropertyElement {
    
    var nodes = Set<Node>()
    
    static var maxUID : UID = 0
    
    //Equatable
    
    public override init() {
        Graph.maxUID += 1
        super.init(uid: Graph.maxUID)
    }
    
    public override init(uid: UID) {
        super.init(uid: uid)
        Graph.maxUID = max(Graph.maxUID,uid)
    }
    
}
