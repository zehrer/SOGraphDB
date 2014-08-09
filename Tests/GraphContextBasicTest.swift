//
//  GraphContextBasicTest.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 13.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import XCTest
import SOGraphDB

class GraphContextBasicTest: XCTestCase {
    
    
    class func createEmptyGraphContextFromURL(url: NSURL) -> SOGraphContext {
        
        var context =  SOGraphContext(URL: url);
        
        //XCTAssertNotNil(context, "context not created?")
        XCTAssertNil(context.error, "error happend?")
        
        return context
    }
    
    class func createEmptyGraphContextFromFileName(fileName: String) -> SOGraphContext {
     
        var url = TestTool.testWrapper(fileName);

        return GraphContextBasicTest.createEmptyGraphContextFromURL(url);
    }
    
    class func createAndDeleteEmptyGraphContextFromFileName(fileName: String) -> SOGraphContext {
        
        var url = TestTool.createNewTestWrapperURL(fileName);
        
        return GraphContextBasicTest.createEmptyGraphContextFromURL(url);
    }
    
    

    //@test
    func testBasicSetup() {
        
        var context: SOGraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName("test0001")
        
        // read node 42 :)
        var testNode = context.readNode(42)
        XCTAssertNil(testNode, "Why is not nil?")
        
        // create node 1
        testNode = context.createNode()
        //XCTAssertTrue(testNode.uid == 1,"Why not id 1?");
        
        // read node 1
        testNode = context.readNode(1)
        XCTAssertNotNil(testNode, "Why nil?")
        //XCTAssertTrue(testNode.id == 1,"Why not id 1?");
        
        // reopen context
        context = GraphContextBasicTest.createEmptyGraphContextFromFileName("test0001")
        
        testNode = context.readNode(1)
        XCTAssertNotNil(testNode, "Why nil?")
        //XCTAssertTrue(testNode.id == 1,"Why not id 1?");
        
        TestTool.deleteFile(context.url)
    }
    
    //@test
    func testListSetup() {
        
        // define variable :)
        var node: SONode!
        
        var context: SOGraphContext = GraphContextBasicTest.createAndDeleteEmptyGraphContextFromFileName("test0002")
        
        // create list node (@1)
        var listNode: SONode = context.createNode()
        XCTAssertTrue(listNode.outRelationshipCount == 0,"Why is count not correct?")
        
        // create 1. list entry (@2)
        node = context.createNode()
        listNode.addRelatedNode(node)
        XCTAssertTrue(listNode.outRelationshipCount == 1,"Why is count not correct?")
        
        // create 2. list entry (@3)
        node = context.createNode()
        listNode.addRelatedNode(node)
        XCTAssertTrue(listNode.outRelationshipCount == 2,"Why is count not correct?")
        
        TestTool.deleteFile(context.url)
    }
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