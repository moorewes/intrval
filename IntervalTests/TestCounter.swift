//
//  TestCounter.swift
//  IntervalTests
//
//  Created by Wes Moore on 9/30/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import XCTest
@testable import Interval

class TestCounter: XCTestCase {

    var counter: Counter!
    
    override func setUp() {
        super.setUp()
        
        let moc = DataController.main.persistentContainer.viewContext
        counter = Counter(context: moc)
    }
    
    func testInterval() {
        // Given:
        let nowPlusTwoMinutes = Calendar.current.date(byAdding: .second, value: 120, to: Date())!
        let nowMinusFourYears = Calendar.current.date(byAdding: .year, value: -4, to: Date())!
        
        // When:
        let intervalTwoMins = Interval(date: nowPlusTwoMinutes, unit: .second)
        let intervalFourYears = Interval(date: nowMinusFourYears, unit: .year)
        
        // Then:
        XCTAssertEqual(intervalTwoMins.value, 119)
        XCTAssertEqual(intervalFourYears.value, -3)
    }
    
    func testScaledTimeIntervalUnit() {
        counter.date = Calendar.current.date(byAdding: .second, value: 120, to: Date())!
        counter.includeTime = true
        
        XCTAssertEqual(counter.scaledTimeIntervalUnit(), .minute)
        
        counter.date = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
        counter.includeTime = false
        
        XCTAssertEqual(counter.scaledTimeIntervalUnit(), .year)
        
    }
    
    func testScaledTimeInterval() {
        // Given
        let nowPlusTwoMinutes = Calendar.current.date(byAdding: .second, value: 120, to: Date())!
        let nowMinusFourYears = Calendar.current.date(byAdding: .year, value: -4, to: Date())!
        let now = Date()
        
        let dates = [nowPlusTwoMinutes, nowMinusFourYears, now]
        let values = [0, 1, -3, 0]
        
        for date in dates {
            counter.date = date
            
            // When
            let interval = counter.scaledTimeInterval()
            
            // Then
            XCTAssertEqual(expectedValue[i], 1)
            XCTAssertEqual(expectedUnit[i], .minute)
            
        }
        
        XCTAssertEqual(intervalNowPlusTwoMinutes.value, 2)
        XCTAssertEqual(intervalNowPlusTwoMinutes.unit, .minute)
        
        counter.date = Calendar.current.date(byAdding: .year, value: 4, to: Date())!
        let intervalNowMinusFourYears = counter.scaledTimeInterval()
        XCTAssertEqual(intervalNowMinusFourYears.value, 3)
        XCTAssertEqual(intervalNowMinusFourYears.unit, .year)
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        let moc = DataController.main.persistentContainer.viewContext
        moc.delete(counter)
        try! moc.save()
    }

}
