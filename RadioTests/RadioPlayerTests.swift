//
//  RadioPlayerTests.swift
//  RadioTests
//
//  Created by Damien Glancy on 17/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest
@testable import Radio

class RadioPlayerTests: BaseXCTestCase {
  
  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: - Tests
 
  func testRadioPlayerIsSingleton() {
    let player1 = RadioPlayer.shared
    let player2 = RadioPlayer.shared
    XCTAssertEqual(player1, player2)
  }
  
}
