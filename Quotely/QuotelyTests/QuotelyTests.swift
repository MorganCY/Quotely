//
//  QuotelyTests.swift
//  QuotelyTests
//
//  Created by Zheng-Yuan Yu on 2021/11/26.
//

import XCTest
@testable import Quotely

class QuotelyTests: XCTestCase {

    var sut: SwipeViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SwipeViewController()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
}
