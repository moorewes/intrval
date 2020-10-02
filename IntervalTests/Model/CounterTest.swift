//
//  CounterTest.swift
//  IntervalTests
//
//  Created by Wes Moore on 9/30/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

import XCTest
import CoreData
@testable import Interval

class CounterTest: XCTestCase {
    
    var now: Date { return Date() }
    var moc: NSManagedObjectContext { return dataController.container.viewContext }

    var sut: Counter!
    var dataController: DataControllerMock!
    
    
    override func setUp() {
        super.setUp()
        dataController = DataControllerMock()
        sut = Counter(context: moc)
    }
    
    override func tearDown() {
        super.tearDown()
        dataController = nil
    }
    
    func testObjectCreation() {
        XCTAssertNotNil(sut.date)
        XCTAssertNotNil(sut.title)
        XCTAssertNotNil(sut.includeTime)
    }
    
    func testScaledTimeIntervalTwoSecondsFutureInludingTime() {
        // Given
        sut.date = Calendar.current.date(byAdding: .second, value: 3, to: now)!
        sut.includeTime = true
        
        // When
        let interval = sut.scaledTimeInterval()
        
        // Then
        XCTAssertEqual(interval.value, 2)
        XCTAssertEqual(interval.unit, .second)
    }
    
    func testScaledTimeIntervalTwoSecondsFutureNoTime() {
        // Given
        sut.date = Calendar.current.date(byAdding: .second, value: 3, to: now)!
        sut.includeTime = false
        
        // When
        let interval = sut.scaledTimeInterval()
        
        // Then
        XCTAssertEqual(interval.value, 0)
        XCTAssertEqual(interval.unit, .day)
    }
    
    func testScaledTimeIntervalThreeMonthsInPast() {
        // Given
        sut.date = Calendar.current.date(byAdding: .day, value: -94, to: now)!
        sut.includeTime = true
        
        // When
        let interval = sut.scaledTimeInterval()
        
        // Then
        XCTAssertEqual(interval.value, -3)
        XCTAssertEqual(interval.unit, .month)
    }

}
