//
//  main.swift
//  XCTestSuiteRun
//
//  Created by Stephan Zehrer on 31.08.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Cocoa
import XCTest

//var suite = XCTestSuite.testSuiteForTestCaseClass(ObjectStoreTests.class) as XCTestSuite
// XCTestSuite *suite = [XCTestSuite testSuiteForTestCaseClass:[MathTest class]];

//var suite = XCTestSuite.testSuiteForTestCaseWithName("ObjectStoreTests") as XCTestSuite

var suite = XCTestSuite(name: "SOGrapheDB")

//var testCase = ObjectStoreTests()
//var testCase1 = ObjectStoreTests.testCaseWithSelector("test1StoreFile") as XCTest!
var testCase2 = ObjectStoreTests.testCaseWithSelector("test2WriteData") as XCTest!

//suite.addTest(testCase1)
suite.addTest(testCase2)

//suite.addTest(ObjectStoreTests.testCaseWithSelector(@selector(test2WriteData)));
//[suite addTest:[VideohogCachingTest testCaseWithSelector:@selector(testCompleteSequentialText)]];
suite.run()
