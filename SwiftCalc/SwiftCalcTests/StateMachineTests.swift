//
//  StateMachineTests.swift
//  SwiftCalc
//
//  Created by Kelvin Hong on 9/28/16.
//  Copyright © 2016 zzeleznick. All rights reserved.
//

import XCTest

class StateMachineTests: XCTestCase {
    
    var sm: StateContext!
    
    override func setUp() {
        super.setUp()
        
        sm = StateContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        print("\n\n\n")
    }
    
    func assertDisplay(expected: String) {
        let d = sm.display()!
        print("Expect \(expected) Got \(d)")
        XCTAssert(d == expected)
    }
    
    func testBasicInput() {
        sm.input("0")
        assertDisplay(expected: "0")
        sm.input("1")
        sm.input("2")
        assertDisplay(expected: "12")
    }
    
    func testBasicInput2() {
        sm.input("0")
        sm.input("-")
        sm.input("7")
        sm.input("+")
        assertDisplay(expected: "-7")
        sm.input("1")
        sm.input("=")
        assertDisplay(expected: "-6") 
    }
    
    func testDecimalInput() {
        sm.input("1")
        sm.input("2")
        sm.input(".")
        sm.input("3")
        sm.input("4")
        assertDisplay(expected: "12.34")
        
        sm.input(".")
        assertDisplay(expected: "12.34")
    }
    
    func testOp() {
        sm.input("1")
        sm.input("2")
        sm.input("+")
        sm.input("3")
        sm.input("+")
        assertDisplay(expected: "15")
        sm.input("4")
        sm.input("=")
        assertDisplay(expected: "19")
    }
    
    func testClear() {
        sm.input("1")
        sm.input("2")
        sm.input("C")
        assertDisplay(expected: "0")
        sm.input("3")
        sm.input("4")
        assertDisplay(expected: "34")
        sm.input("-")
        sm.input("5")
        sm.input("=")
        assertDisplay(expected: "29")
        sm.input("C")
        assertDisplay(expected: "0")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
