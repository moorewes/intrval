//
//  DataControllerTest.swift
//  IntervalTests
//
//  Created by Wes Moore on 10/1/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

@testable import Interval
import XCTest

class DataControllerTest: XCTestCase {
    
    var sut: DataControllerMock!

    override func setUpWithError() throws {
        sut = DataControllerMock()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    // MARK: - Tests
    
    func testNewCounter() {
        let counter = sut.newCounter()
        
        XCTAssertNotNil(counter.date)
        XCTAssertNotNil(counter.title)
        XCTAssertNotNil(counter.includeTime)
        XCTAssertNotNil(counter.id)
    }
    
    func testNewCounterInMOC() {
        let moc = sut.container.newBackgroundContext()
        moc.perform {
            let counter = self.sut.newCounter(in: moc)
            
            XCTAssertNotNil(counter.date)
            XCTAssertNotNil(counter.title)
            XCTAssertNotNil(counter.includeTime)
            XCTAssertNotNil(counter.id)
            XCTAssert(counter.managedObjectContext!.hasChanges)
        }
        
    }
    
    func testSaveCounters() {
        let _ = createCounters(10)
        
        sut.saveCounters()
        
        XCTAssert(sut.viewContext.hasChanges == false)
    }
    
    // MARK: Helper Methods
    
    func createCounters(_ count: Int) -> [Counter] {
        var counters = [Counter]()
        while counters.count < count {
            counters.append(sut.newCounter())
        }
        
        return counters
    }

}
