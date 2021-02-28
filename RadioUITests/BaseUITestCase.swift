//
//  BaseUITestCase.swift
//  RadioUITests
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest

class BaseUITestCase: BaseXCTestCase {

  // MARK: - Properties
  
  var app = XCUIApplication()
  var menuBarsQuery: XCUIElementQuery?
  var menuBarItem: XCUIElement?
  
  // MARK: - Common lifecycle
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    menuBarsQuery = app.menuBars
    menuBarItem = menuBarsQuery!.children(matching: .statusItem).element
    app.launchEnvironment = ["TEST_MODE": "true"]
    app.launch()
  }
  
  override func tearDown() {
    super.tearDown()
    menuBarsQuery = nil
    menuBarItem = nil
  }
  
  // MARK: - Common functions
  
  func tapMenuBar() {
    menuBarItem!.click()
  }
  
  func findRadioDisplayView() -> XCUIElement {
    return menuBarsQuery!.menuItems.containing(.staticText, identifier: "StationNameTextField").element(boundBy: 0)
  }
  
  func clearTextField(_ textField: XCUIElement) {
    let deleteString = "".padding(toLength: (textField.value as? String ?? "").count, withPad: XCUIKeyboardKey.delete.rawValue, startingAt: 0)
    textField.click()
    textField.typeText(deleteString)
  }
}

// MARK: - Extensions

extension XCTestCase {
  
  // MARK: - Functions
  
  func wait(forElement element: XCUIElement, timeout: TimeInterval) {
    let predicate = NSPredicate(format: "exists == 1")
    expectation(for: predicate, evaluatedWith: element)
    waitForExpectations(timeout: timeout)
  }
}
