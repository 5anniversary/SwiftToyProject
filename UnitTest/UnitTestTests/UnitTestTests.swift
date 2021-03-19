//
//  UnitTestTests.swift
//  UnitTestTests
//
//  Created by 오준현 on 2021/03/18.
//

import XCTest
@testable import UnitTest

class UnitTestTests: XCTestCase {
  
  override func setUpWithError() throws {
    
  }
  
  override func tearDownWithError() throws {
    
  }
  
  func testExample() throws {
    
  }
  
  func testPerformanceExample() throws {
    
    self.measure {
      
    }
  }
  
  func testVanillaLeapYear() {
    let year = Year(calendarYear: 1996)
    XCTAssertTrue(year.isLeapYear)
  }
  
  func testAnyOldYear() {
    let year = Year(calendarYear: 1997)
    XCTAssertTrue(!year.isLeapYear)
  }
  
  func testCentury() {
    let year = Year(calendarYear: 1900)
    XCTAssertTrue(!year.isLeapYear)
  }
  
  func testExceptionalCentury() {
    let year = Year(calendarYear: 2400)
    XCTAssertTrue(year.isLeapYear)
  }
}

struct Year {
  let calendarYear: Int
  var isLeapYear: Bool {
    return calendarYear%4 == 0 &&
      (calendarYear%100 != 0 || calendarYear%400 == 0)
  }
}
