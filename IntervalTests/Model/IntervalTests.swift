//
//  IntervalTests.swift
//  IntervalTests
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import XCTest
@testable import Interval

class IntervalTests: XCTestCase {
    
    var sut: Interval!
    
    var now: Date { return Date() }
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.sut = nil
    }
    
    func testOneMonthInFuture() {
        // Given
        let fiveWeeksLater = Calendar.current.date(byAdding: .day, value: 32, to: now)!
        
        // When
        sut = Interval(date: fiveWeeksLater, unit: .month)
        
        // Then
        XCTAssertEqual(sut.value, 1)
        XCTAssertEqual(sut.unit, .month)
    }

    func testOneMonthInPast() {
        // Given
        let fiveWeeksBefore = Calendar.current.date(byAdding: .day, value: -32, to: now)!
        
        // When
        sut = Interval(date: fiveWeeksBefore, unit: .month)
        
        // Then
        XCTAssertEqual(sut.value, -1)
        XCTAssertEqual(sut.unit, .month)
    }
    
    func testTwoSecondsInFuture() {
        // Given
        let threeSecondsLater = Calendar.current.date(byAdding: .second, value: 3, to: now)!
        
        // When
        sut = Interval(date: threeSecondsLater, unit: .second)
        
        // Then
        XCTAssertEqual(sut.value, 2)
        XCTAssertEqual(sut.unit, .second)
    }
    
    
    
}
