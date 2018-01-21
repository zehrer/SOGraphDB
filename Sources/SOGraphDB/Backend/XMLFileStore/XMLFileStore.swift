//
//  XMLFileStore.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class XMLFileStore : SOGraphDBStore {

    //open let xmlFileURL : URL
    
    //MARK:  -
    
    public required init()  {
    }
    
    public required init(url: URL) throws {
        //self.xmlFileURL = url
        //readXMLFile()
    }
    
    //MARK: - Graphs
    
    var graphList = [Graph]()
    
    public func register(_ graph: Graph) {
        graphList.append(graph)
    }

    //MARK: - Node
    
    //var nodeList = [Node]()
    var nodeDict = [Int: Node]()
    
    var maxNodeUID : UID = 0
    
    // Register a node
    //
    public func register(_ node: Node) {
        if let uid = node.uid {
            maxNodeUID = max(maxNodeUID,uid) + 1
        } else {
            maxNodeUID += 1
            node.uid = maxNodeUID
        }
        
        nodeDict[node.uid] = node
    }
    
    public func findNodeBy(uid: UID?) -> Node? {
        
        if uid != nil {
            return self.nodeDict[uid!]
        }
        return nil
    }
    
    func onAllNodes(_ closure: (Node) -> Void) {
        for node in nodeDict.values {
            closure(node)
        }
    }
    
    public func update(_ aNode: Node) {
        // No implementation required for XMLFileStore
    }
    
    public func delete(_ aNode: Node) {
        // No implementation required for XMLFileStore
    }
    
    //MARK: - Relationship
    
    var relationshipList = [Relationship]()
    var maxRelationshipUID : UID = 0
    
    func onAllRelationships(_ closure: (Relationship) -> Void) {
        for rel in relationshipList {
            closure(rel)
        }
    }
    
    // Register a new or loaded relationship
    public func register(_ rel: Relationship) {
        
        if let uid = rel.uid {
            maxRelationshipUID = max(maxRelationshipUID,uid) + 1
        } else {
            maxRelationshipUID += 1
            rel.uid = maxRelationshipUID
        }
        
        relationshipList.append(rel)
    }
    
    public func delete(_ aRelationship: Relationship) {
        // TODO
    }
    
    public func update(_ relationship: Relationship) {
        // No implementation required for XMLFileStore
    }
    
    public func findRelationship(from startNode: Node, to endNode: Node) -> Relationship?{
        // read data
        
        let outRelationships = startNode.outRelationships
        
        for rel in outRelationships {
            if rel.endNode === endNode {
                return rel
            }
        }
        
        return nil
    }
    
     //MARK: - Persistent
    
   /**
    
    func readXMLFile() throws {
        
        //var error : NSError?
        
        // TODO: ERROR Handling
        let xmlFileWrapper: FileWrapper? = try! FileWrapper(url: xmlFileURL, options:FileWrapper.ReadingOptions.immediate)
        
        if xmlFileWrapper != nil {
          // TODO READ DATA
        }
    }
    
    
    
    func writeXMLFile() throws {
        
        // writeHeader
        
        // writeNodes
        for node in nodeList {
            write(node: Node, to: FileWrapper)
        }
    
        // writeFooter
    }
    
    func write(node: Node, to fileWrapper: FileWrapper)
 
    */
    
}
