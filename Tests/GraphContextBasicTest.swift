//
//  GraphContextBasicTest.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 13.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import XCTest
import SOGraphDB

class GraphContextBasicTest: XCTestCase, NSCacheDelegate {
    
    
    class func createEmptyGraphContextFromURL(url: NSURL) -> GraphContext {
        
        var context =  GraphContext(url: url);
        
        //XCTAssertNotNil(context, "context not created?")
        XCTAssertNil(context.error, "error happend?")
        
        return context
    }
    
    class func createEmptyGraphContextFromFileName(fileName: String) -> GraphContext {
     
        var url = TestTool.testWrapper(fileName);

        return GraphContextBasicTest.createEmptyGraphContextFromURL(url);
    }
    
    class func createAndDeleteEmptyGraphContextFromFileName(fileName: String) -> GraphContext {
        
        var url = TestTool.createNewTestWrapperURL(fileName);
        
        return GraphContextBasicTest.createEmptyGraphContextFromURL(url);
    }
    
    
    let fileName1 = "test0001"
    
    //@test
    func testBasicSetup() {
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName1)
        
        // read node 42 :)
        var testNode = context.readNode(42)
        XCTAssertNil(testNode, "Why is not nil?")
        
        // create node 1
        testNode = context.createNode()
        XCTAssertTrue(testNode!.uid == 1,"Why not id 1?");
        
        // read node 1
        testNode = context.readNode(1)
        XCTAssertNotNil(testNode, "Why nil?")
        XCTAssertTrue(testNode!.uid == 1,"Why not id 1?");
        
        // reopen context
        context = GraphContextBasicTest.createEmptyGraphContextFromFileName(fileName1)
        
        testNode = context.readNode(1)
        XCTAssertNotNil(testNode, "Why nil?")
        XCTAssertTrue(testNode!.uid == 1,"Why not id 1?");
        
        TestTool.deleteFile(context.url)
    }
    
    let fileName2 = "test0002"
    
    //@test
    func testListSetup() {
        
        // define variable :)
        var node: Node!
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName2)
        
        // create list node (@1)
        var listNode = context.createNode()
        XCTAssertTrue(listNode.outRelationshipCount == 0,"Why is count not correct?")
        
        // create 1. list entry (@2)
        node = context.createNode()
        listNode.addOutRelationshipNode(node)
        XCTAssertTrue(listNode.outRelationshipCount == 1,"Why is count not correct?")
        XCTAssertTrue(node.inRelationshipCount == 1,"Why is count not correct?")
        
        // create 2. list entry (@3)
        node = context.createNode()
        listNode.addOutRelationshipNode(node)
        XCTAssertTrue(listNode.outRelationshipCount == 2,"Why is count not correct?")
        XCTAssertTrue(node.inRelationshipCount == 1,"Why is count not correct?")
        
        TestTool.deleteFile(context.url)
    }
    
    let fileName3 = "test0003"
    
    func testBigGraph1() {
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName3)
        
        context.createNode()
        
        var tool = TestTool(context: context) // )[[SOTestTools alloc] initWithContext:context];
        
        context.cacheLimit(5000)
        
        // 8 = 511 nodes ; 10 = 2047 nodes ; 15 = 65535 nodes
        var rootNode = tool.createNodeGraphWithDepth(10)
        
        var count = TestTool.traverseGraphFromNode(rootNode)
        
        XCTAssertTrue(tool.createdNodes == count, "Node numer is not the same");
        //XCTAssertTrue(url.isFileExisting, "File deleted?");
        
    }
    
    let fileName4 = "test0004"
    
    func testBigGraph2() {
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName4)
        var tool = TestTool(context: context)
        
        //context.cacheDelegate(self)
        context.cacheLimit(200000)
        
        //8 = 511 nodes ; 9 = 1023;  10 = 2047 nodes ; 15 = 65535 nodes ; 18 = 524287
        var rootNode = tool.createNodeGraphWithDepth(13)
        
        tool.traverseGraphFromNode(rootNode)
        
        XCTAssertTrue(tool.createdNodes == tool.recursiveNodeCount, "Node numer is not the same");
        //XCTAssertTrue(url.isFileExisting, "File deleted?");
        
        context.cacheDelegate(nil)

    }
    
    func cache(cache: NSCache, willEvictObject obj: AnyObject) {
        
        if let node = obj as? Node {
            println("Cache \(cache.name) will Evict Object \(node.uid)")
        }

    }
    
    // MARK: Property tests
    
    let fileName5 = "test0005"
    
    func testPropertyDelete() {
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName5)
        
        var nameType = context.createNode()  // @1
        
        var data = context.createNode() // @2
        
        data[nameType].stringValue = testStringUTF8U2
        
        var text = data[nameType].stringValue
        
        XCTAssertTrue(testStringUTF8U2 == text, "text not similar")
        
        data.deletePropertyForKey(nameType)
        
        XCTAssertFalse(data.containsProperty(nameType), "Property not deleted?")
        
    }
    
     let fileName6 = "test0006"
    
    func testRelationshiDelete() {
        
        var context: GraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName(fileName6)
        
        var es = Array<Node>()
        
        var data1 = context.createNode()  // @1
        var data2 = context.createNode()  // @2
        
        var rel = data1.addOutRelationshipNode(data2) //@1
        XCTAssertNotNil(rel,  "No Relationship?")
        
        var outRelations = data1.outRelationships
        XCTAssertTrue(outRelations.count == 1,"")
        
        var inRelations = data2.inRelationships
        XCTAssertTrue(inRelations.count == 1,"")
        
        if rel != nil {
            rel!.delete()
        }
        
        XCTAssertTrue(data1.outRelationships.count == 0,"")
        XCTAssertTrue(data2.inRelationships.count == 0,"")
        
        rel = context.readRelationship(1)
        XCTAssertNil(rel, "Not Deleted");
        
    }
    
/**


*/
}


/**
func testExample() {
// This is an example of a functional test case.
XCTAssert(true, "Pass")
}

func testPerformanceExample() {
// This is an example of a performance test case.
self.measureBlock() {
// Put the code you want to measure the time of here.
}
}
*/