//
//  GlobalFunctionTests.swift
//  RadioTests
//
//  Created by Damien Glancy on 16/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest
@testable import Radio

class GlobalFunctionTests: BaseXCTestCase {
  
  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
    setAudioNotMuted()
  }
  
  override func tearDown() {
    super.tearDown()
    UserDefaults.standard.removePersistentDomain(forName: kAppBundleId)
    UserDefaults.standard.synchronize()
  }
  
  // MARK: - Tests
  
  func testSetAudioVolumeNoSave() {
    setAudioVolume(0.1)
    XCTAssertEqual(0.1, RadioPlayer.shared.volume)
    XCTAssertNotEqual(0.1, UserDefaults.standard.float(forKey: UserDefaultKeys.CurrentVolume.rawValue))
  }
  
  func testSetAudioVolumeSave() {
    setAudioVolume(0.1, save: true)
    XCTAssertEqual(0.1, RadioPlayer.shared.volume)
    XCTAssertEqual(0.1, UserDefaults.standard.float(forKey: UserDefaultKeys.CurrentVolume.rawValue))
  }
  
  func testSetAudioMuted() {
    XCTAssertFalse(RadioPlayer.shared.muted)
    XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue))
    setAudioMuted()
    XCTAssertTrue(RadioPlayer.shared.muted)
    XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue))
  }
  
  func testSetAudioNotMuted() {
    setAudioMuted()
    XCTAssertTrue(RadioPlayer.shared.muted)
    XCTAssertTrue(UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue))
    setAudioNotMuted()
    XCTAssertFalse(RadioPlayer.shared.muted)
    XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue))
  }
  
  func testNotification() {
    let expectation = self.expectation(description: "Network Expectation")

    sendLocalNotification(title: "Test Title", subtitle: "Test Subtitle") { _ in
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
}
