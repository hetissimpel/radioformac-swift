//
//  RadioUITests.swift
//  RadioUITests
//
//  Created by Damien Glancy on 06/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest

class RadioUITests: BaseUITestCase {
  
  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
    tapMenuBar()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: - Tests
  
  func testOpenCloseStatusBarMenu() {    
    XCTAssertNotNil(menuBarsQuery!.menuItems["Preferences"])
    XCTAssertNotNil(menuBarsQuery!.menuItems["Quit Radio"])
  }
  
  func testRadioDisplayView() {
    let radioDisplayView = findRadioDisplayView()
    
    XCTAssertTrue(radioDisplayView.staticTexts["StationNameTextField"].exists)
    XCTAssertEqual("No Station", radioDisplayView.staticTexts["StationNameTextField"].value as! String)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "PlayBtn").element.exists)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "FavBtn").element.exists)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "RecordBtn").element.exists)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "MuteBtn").element.exists)
    XCTAssertTrue(radioDisplayView.children(matching: .slider).matching(identifier: "VolumeSlider").element.exists)
  }
  
  func testOpenClosePreferencesDialog() {
    menuBarsQuery!.menuItems["Preferences..."].click()
    app.windows["Stations"].buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testOpenStationsPreferencesDialog() {
    menuBarsQuery!.menuItems["Preferences..."].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertTrue(stationsWindow.searchFields["SearchField"].exists)
    XCTAssertTrue(stationsWindow.tables["StationsTable"].exists)
    XCTAssertTrue(stationsWindow.buttons["PlayBtn"].exists)
    XCTAssertTrue(stationsWindow.buttons["EditBtn"].exists)
    XCTAssertTrue(stationsWindow.buttons["DeleteBtn"].exists)
    XCTAssertTrue(stationsWindow.buttons["AddNewStationBtn"].exists)
    
//    let touchBar = app.children(matching: .touchBar).matching(identifier: "StationsTouchBar").element
//    XCTAssertTrue(touchBar.exists)
    
    stationsWindow.buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testOpenFavouritesPreferencesDialog() {
    menuBarsQuery!.menuItems["Preferences"].click()
    
    app.windows["Stations"].toolbars.buttons["Favorites"].click()
    app.windows["Favorites"].buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testOpenRecordingsPreferencesDialog() {
    menuBarsQuery!.menuItems["Preferences"].click()
    
    app.windows["Stations"].toolbars.buttons["Recordings"].click()
    app.windows["Recordings"].buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testPrimaryControlsWithNoStationSelected() {
    let radioDisplayView = findRadioDisplayView()
    XCTAssertFalse(radioDisplayView.children(matching: .checkBox).matching(identifier: "PlayBtn").element.isEnabled)
    XCTAssertFalse(radioDisplayView.children(matching: .checkBox).matching(identifier: "FavBtn").element.isEnabled)
    XCTAssertFalse(radioDisplayView.children(matching: .checkBox).matching(identifier: "RecordBtn").element.isEnabled)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "MuteBtn").element.isEnabled)
  }
  
  func testPrimaryControlsWithStationSelected() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    stationsWindow.buttons["Add New Station..."].click()
    
    let addNewStationWindow = stationsWindow.sheets["StationDetailSheet"]
    addNewStationWindow.textFields["UrlTextField"].typeText("example.com/station.mp3\t")
    addNewStationWindow.textFields["NameTextField"].typeText("A station name")
    addNewStationWindow.buttons["Ok"].click()
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
    table.children(matching: .tableRow).element(boundBy: 0).cells.containing(.staticText, identifier:"NameCell").element.doubleClick()
    stationsWindow.buttons[XCUIIdentifierCloseWindow].click()
    
    tapMenuBar()
    let radioDisplayView = findRadioDisplayView()
    XCTAssertEqual("A station name", radioDisplayView.staticTexts["StationNameTextField"].value as! String)
    
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "PlayBtn").element.isEnabled)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "FavBtn").element.isEnabled)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "RecordBtn").element.isEnabled)
    XCTAssertTrue(radioDisplayView.children(matching: .checkBox).matching(identifier: "MuteBtn").element.isEnabled)
  }
  
  func testMute() {
    let radioDisplayView = findRadioDisplayView()
    let muteBtn = radioDisplayView.children(matching: .checkBox).matching(identifier: "MuteBtn").element
    XCTAssertTrue(muteBtn.exists)
    XCTAssertTrue(muteBtn.value as! Int == 0)
    muteBtn.click()
    XCTAssertTrue(muteBtn.value as! Int == 1)
    muteBtn.click()
    XCTAssertTrue(muteBtn.value as! Int == 0)
  }
  
  func testAdjustVolumeControl() {
    let volumeSlider = menuBarsQuery!.sliders["VolumeSlider"]
    XCTAssertNotNil(volumeSlider)
    volumeSlider.adjust(toNormalizedSliderPosition: 1.0)
    tapMenuBar() // close
    
    tapMenuBar() // open
    XCTAssertTrue((volumeSlider.value as! NSNumber).doubleValue <= 1.0)
    volumeSlider.adjust(toNormalizedSliderPosition: 0.0)
    tapMenuBar() // close
    
    tapMenuBar() // open
    XCTAssertTrue((volumeSlider.value as! NSNumber).doubleValue >= 0.0)
    volumeSlider.adjust(toNormalizedSliderPosition: 0.5)
    tapMenuBar() // close
    
    tapMenuBar() // open
    XCTAssertTrue((volumeSlider.value as! NSNumber).doubleValue > 0.0 && (volumeSlider.value as! NSNumber).doubleValue < 1.0 )
  }
}

