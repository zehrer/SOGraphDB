//
//  TestTool.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 13.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import SOGraphDB
import XCTest

class TestTool {
    
    static let NUM_LINKED_NODES : Int = 2
    
    var context : GraphContext
    var keyNode : Node? = nil
    var createdNodes = 0
    
    var recursiveSet =  Set<Node>()
    var recursiveNodeCount = 0
    
    class func tempDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    /**
     * This method add ".wrapper" at the end
     */
    class func testWrapper(_ fileName: String) -> URL {
    
        let tempURL = TestTool.tempDirectory()
    
        return tempURL.appendingPathComponent("\(fileName).wrapper")
    
    }
    
    class func createNewTestWrapperURL(_ fileName: String) -> URL {
        
        let url = TestTool.testWrapper(fileName)
        
        print("URL: \(url.path)")
        
        url.deleteFile();
        
        return url;
        
    }
    
    class func deleteFile(_ url: URL) {
        
        url.deleteFile();
        
        XCTAssertFalse(url.isFileExisting(), "File not deleted?");
        
    }
    
    class func addDecreasingLinksToNodes(_ nodes: [Node], withContext context:GraphContext) -> [Node] {
        
        var result = Array<Node>()
        
        for var i = 0; i < nodes.count; i += NUM_LINKED_NODES {
            let link = context.createNode()
            result.append(link)
            
            let max = i + NUM_LINKED_NODES
            
            for j in i..<max {
                let node = nodes[j]
                node.addOutRelationshipNode(link)
            }
        }

        return result
    }
    
    init(context: GraphContext) {
        self.context = context
        keyNode = context.readNode(1)
        
    }
    
    func addINcreasingLinksToNodes(_ nodes : [Node]) -> [Node] {
        
        var result = Array<Node>()
        
        for node in nodes {
            
            for _ in 0..<TestTool.NUM_LINKED_NODES {
                let link = context.createNode()
                result.append(link)
                node.addOutRelationshipNode(link)
            }
            
            if keyNode != nil {
                //[node setLongValue:[[node id] longValue]forKey:self.keyNode];
            }
            
        }
        
        return result
    }
    
    //8 = 511 nodes ; 9 = 1023;  10 = 2047 nodes ; 15 = 65535 nodes ; 18 = 524287
    func createNodeGraphWithDepth(_ graphDepth : Int) -> Node {
        
        let head = context.createNode()
        
        var nodes = Array<Node>(arrayLiteral: head)
        
        createdNodes = 1
        for _ in 0..<graphDepth {
            nodes = addINcreasingLinksToNodes(nodes)
            createdNodes += nodes.count
        }
        
        print("Created \(createdNodes) nodes")
        
        return head
    }
    
    func recursivelyTraverse(_ aNode : Node) {
        var nodes = aNode.relatedOutNodes()
        
        for node in nodes {
            if !recursiveSet.contains(node) {
                recursiveSet.insert(node)
                
                recursivelyTraverse(node)
            }
        }
        
        self.recursiveNodeCount += 1
    }
    
    func traverseGraphFromNode(_ startNode : Node) {
        
        let startDate = Date()
        recursiveSet = Set<Node>(arrayLiteral: startNode)
        
        recursivelyTraverse(startNode)
        
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate)
        
        print("Visited \(recursiveNodeCount) nodes in \(interval) secondes")
    }
    
    class func traverseGraphFromNode(_ startNode : Node) -> Int {
        let startDate = Date()
        
        var visitedNodes = Set<Node>(arrayLiteral: startNode)
        var queue = Array<Node>(arrayLiteral: startNode)
        var nodeCount = 0
        
        while queue.count > 0 {
            var node = queue.last!  // not nil tested by count check
            var nodes = node.relatedOutNodes()
            
            for aNode in nodes {
                if !visitedNodes.contains(aNode) {
                    visitedNodes.insert(aNode)
                    queue.insert(aNode, atIndex: 0)
                    //println("Node :\(aNode.uid)")
                    //nodeCount++
                }
            }
            queue.removeLast()
            nodeCount += 1

        }
        
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate)
        
        print("Visited \(nodeCount) nodes in \(interval) secondes")
        
        return nodeCount
    }

    /**

    
    */
    
    
    class func createEmptyGraphContextFromURL(_ url: URL) -> GraphContext {
        
        //var context =
        
        //XCTAssertNotNil(context, "context not created?")
        //XCTAssertNil(context.error, "error happend?")
        
        return GraphContext(url: url)
    }
    
    class func createEmptyGraphContextFromFileName(_ fileName: String) -> GraphContext {
        
        let url = testWrapper(fileName);
        
        return createEmptyGraphContextFromURL(url);
    }
    
    class func createAndDeleteEmptyGraphContextFromFileName(_ fileName: String) -> GraphContext {
        
        let url = createNewTestWrapperURL(fileName);
        
        return createEmptyGraphContextFromURL(url);
    }
}
