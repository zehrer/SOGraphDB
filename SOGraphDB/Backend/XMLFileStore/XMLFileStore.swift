//
//  XMLFileStore.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class XMLFileStore : SOGraphDBStore {

    open let xmlFileURL : URL
    var nodeList = [Node]()
    var relationshipList = [Relationship]()
    
    //MARK:  -
    
    public required init(url: URL) throws {
        self.xmlFileURL = url
        //readXMLFile()
    }
    
    //MARK: - Node
    
    public func register(_ aNode: Node) {
    }
    
    public func update(_ aNode: Node) {
        // TODO
    }
    
    public func delete(_ aNode: Node) {
        // TODO
    }
    
    //MARK: - Relationship
    
    public func register(_ aRelationship: Relationship) {
        // TODO
    }
    
    public func delete(_ aRelationship: Relationship) {
        // TODO
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
    

    
    public func update(_ aRelationship: Relationship) {
        // TODO
    }
    

    public func readXMLFile() throws {
        
        //var error : NSError?
        
        // TODO: ERROR Handling
        let xmlFileWrapper: FileWrapper? = try! FileWrapper(url: xmlFileURL, options:FileWrapper.ReadingOptions.immediate)
        
        if xmlFileWrapper != nil {
          // TODO READ DATA
        }
    }
    
}
