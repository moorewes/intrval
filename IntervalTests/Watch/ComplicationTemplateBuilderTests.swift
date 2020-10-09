//
//  ComplicationTemplateBuilderTests.swift
//  IntervalTests
//
//  Created by Wes Moore on 10/8/20.
//  Copyright © 2020 Wes Moore. All rights reserved.
//

@testable import Interval
import XCTest

class ComplicationTemplateBuilderTests: XCTestCase {
    
    var sut: ComplicationTemplateBuilder!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCounterTemplate() {
        let counter = WatchCounter(id: UUID(), date: Date(), title: "Test Counter", includeTime: false)
        
        let sut = ComplicationTemplateBuilder(counter: counter)
        let template = sut.template(for: .modularSmall)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
