//
//  SOGraphDBStoreTests.swift
//  SOGraphDBTests
//
//  Created by Stephan Zehrer on 16.02.18.
//

import XCTest
@testable import SOGraphDB

class SOGraphDBStoreTests: XCTestCase {
    
    var store : SOGraphDBStore! = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        store = XMLFileStore()
        //store = TestDBStore()
    }
    
    func testRegisterNode() {
        
        let node = Node()
        
        store.register(node)
        
        XCTAssert(node.graphStore != nil, "no graphStore set for node")
    }
    
    func createNode() -> Node {
        let node = Node()
        store.register(node)
        return node
    }
    
    
    func testNodePropertyString() {
        let node = createNode()
        
        node[node].stringValue = "test"
        
        XCTAssert(node[node].stringValue == "test")
    }
    
    func testNodePropertyInt() {
        let node = createNode()
        
        node[node].intValue = 42
        
        XCTAssert(node[node].intValue == 42)
        XCTAssert(node[node].type == .integer)
    }
    
    func testNodePropertyBool() {
        let node = createNode()
        
        node[node].boolValue = true
        
        XCTAssert(node[node].boolValue == true)
    }
    
    // MARK: - Relationship
    
    func createRelationship() -> Relationship {
        let nodeA = createNode()
        let nodeB = createNode()
        
        return nodeA.addOutRelationshipTo(endNode: nodeB)
    }
    
    func testRelPropertyString() {
        let typeNode = createNode()
        
        let rel = createRelationship()
        rel[typeNode].stringValue = "test"
        
        XCTAssert(rel[typeNode].stringValue == "test")
        XCTAssert(rel[typeNode].type == .string)
    }
    
    func testRelPropertyInt() {
        let typeNode = createNode()
        
        let rel = createRelationship()
        rel[typeNode].intValue = 42
        
        XCTAssert(rel[typeNode].intValue == 42)
        XCTAssert(rel[typeNode].type == .integer)
    }
    
    func testCreateRelationship0() {
        
        let node = createNode()
        
        node.addOutRelationshipTo(endNode: node)
        
        XCTAssert(node.outRelationshipCount == 1)
        XCTAssert(node.inRelationshipCount == 1)
    }
    
    
    func testCreateRelationship1() {
        
        let rel = createRelationship()
        
        XCTAssert(rel.startNode.outRelationshipCount == 1)
        XCTAssert(rel.startNode.inRelationshipCount == 0)
        
        XCTAssert(rel.endNode.outRelationshipCount == 0)
        XCTAssert(rel.endNode.inRelationshipCount == 1)
    }
    
    func testCreateRelationship2() {
        
        let nodeA = createNode()
        let nodeB = createNode()
        let nodeC = createNode()
        
        nodeA.addOutRelationshipTo(endNode: nodeB)
        nodeB.addOutRelationshipTo(endNode: nodeC)
        nodeC.addOutRelationshipTo(endNode: nodeA)
        
        XCTAssert(nodeA.outRelationshipCount == 1)
        XCTAssert(nodeA.inRelationshipCount == 1)
        
        XCTAssert(nodeB.outRelationshipCount == 1)
        XCTAssert(nodeB.inRelationshipCount == 1)
        
        XCTAssert(nodeC.outRelationshipCount == 1)
        XCTAssert(nodeC.inRelationshipCount == 1)
    }


    /**
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */

 }
