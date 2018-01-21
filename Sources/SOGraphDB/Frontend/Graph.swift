//
//  Graph.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 21.01.18.
//

import Foundation

public class Graph { // PropertyElement
    
    public var uid: UID!
    
    public var graphStore: SOGraphDBStore!
    public var dirty: Bool = true

    var nodes = Set<Node>()
    
    static var maxUID : UID = 0
    
    //Equatable
    
    public  init() {
        Graph.maxUID += 1
        self.uid = Graph.maxUID
    }
    
    public init(uid: UID) {
        self.uid = uid
        Graph.maxUID = max(Graph.maxUID,uid)
    }
    
    public func add(_ node: Node) {
        nodes.insert(node)
    }
    
    public func remove(_ node: Node) {
        nodes.remove(node)
    }
}
