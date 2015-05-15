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
    
    class func tempDirectory() -> NSURL {
        return NSURL(fileURLWithPath: NSTemporaryDirectory())!
    }
    
    /**
     * This method add ".wrapper" at the end
     */
    class func testWrapper(fileName: String) -> NSURL {
    
        var tempURL = TestTool.tempDirectory()
    
        return tempURL.URLByAppendingPathComponent("\(fileName).wrapper")
    
    }
    
    class func createNewTestWrapperURL(fileName: String) -> NSURL {
        
        var url = TestTool.testWrapper(fileName)
        
        println("URL: \(url.path!)")
        
        url.deleteFile();
        
        return url;
        
    }
    
    class func deleteFile(url: NSURL) {
        
        url.deleteFile();
        
        XCTAssertFalse(url.isFileExisting(), "File not deleted?");
        
    }
    
    class func addDecreasingLinksToNodes(nodes: [Node], withContext context:GraphContext) -> [Node] {
        
        var result = Array<Node>()
        
        for var i = 0; i < nodes.count; i += NUM_LINKED_NODES {
            let link = context.createNode()
            result.append(link)
            
            let max = i + NUM_LINKED_NODES
            
            for j in i..<max {
                var node = nodes[j]
                node.addOutRelationshipNode(link)
            }
        }

        return result
    }
    


    
    init(context: GraphContext) {
        self.context = context
        keyNode = context.readNode(1)
        
    }
    
    func addINcreasingLinksToNodes(nodes : [Node]) -> [Node] {
        
        var result = Array<Node>()
        
        for node in nodes {
            
            for i in 0..<TestTool.NUM_LINKED_NODES {
                var link = context.createNode()
                result.append(link)
                node.addOutRelationshipNode(link)
            }
            
            if keyNode != nil {
                //[node setLongValue:[[node id] longValue]forKey:self.keyNode];
            }
            
        }
        
        return result
    }
    
    func createNodeGraphWithDepth(graphDepth : Int) -> Node {
        
        var head = context.createNode()
        
        var nodes = Array<Node>(arrayLiteral: head)
        
        createdNodes = 1
        for i in 0..<graphDepth {
            nodes = addINcreasingLinksToNodes(nodes)
            createdNodes += nodes.count
        }
        
        println("Created \(createdNodes) nodes")
        
        return head
    }
    
    func recursivelyTraverse(aNode : Node) {
        var nodes = aNode.relatedOutNodes()
        
        for node in nodes {
            if !recursiveSet.contains(node) {
                recursiveSet.insert(node)
                
                recursivelyTraverse(node)
            }
        }
        
        self.recursiveNodeCount++
    }
    
    func traverseGraphFromNode(startNode : Node) {
        
        let startDate = NSDate()
        recursiveSet = Set<Node>(arrayLiteral: startNode)
        
        recursivelyTraverse(startNode)
        
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate)
        
        println("Visited \(recursiveNodeCount) nodes in \(interval) secondes")
    }
    
    
    
    class func traverseGraphFromNode(startNode : Node) -> Int {
        let startDate = NSDate()
        
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
            nodeCount++

        }
        
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate)
        
        println("Visited \(nodeCount) nodes in \(interval) secondes")
        
        return nodeCount
    }

    /**

    
    */
}
