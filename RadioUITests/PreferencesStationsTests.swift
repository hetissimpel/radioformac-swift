//
//  PreferencesStationsTests.swift
//  RadioUITests
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest

class PreferencesStationsTests: BaseUITestCase {
  
  // MARK: - Lifecycle
  
  // MARK: - Lifecycle

  override func setUp() {
    super.setUp()
    tapMenuBar()
  }
  
  // MARK: - Tests
  
  func testAddNewStationDialog() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertFalse(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A station name")
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
    
    let cells = table.tableRows.element(boundBy: 0).cells
    XCTAssertEqual("A station name", cells.staticTexts["NameCell"].value as! String)
    XCTAssertEqual("A station description", cells.staticTexts["DescriptionCell"].value as! String)
    XCTAssertEqual("A station city", cells.staticTexts["CityCell"].value as! String)
    XCTAssertEqual("A station country", cells.staticTexts["CountryCell"].value as! String)
    
    XCTAssertTrue(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["DeleteBtn"].isEnabled)
  }
  
  func testEditStationDialog() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    addNewStation(stationName: "A station name")
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
    
    let cells = table.tableRows.element(boundBy: 0).cells
    XCTAssertEqual("A station name", cells.staticTexts["NameCell"].value as! String)
    XCTAssertEqual("A station description", cells.staticTexts["DescriptionCell"].value as! String)
    XCTAssertEqual("A station city", cells.staticTexts["CityCell"].value as! String)
    XCTAssertEqual("A station country", cells.staticTexts["CountryCell"].value as! String)
    
    stationsWindow.buttons["Edit..."].click()
    let addNewStationWindow = stationsWindow.sheets["StationDetailSheet"]
    clearTextField(addNewStationWindow.textFields["NameTextField"])
    addNewStationWindow.textFields["NameTextField"].typeText("A new name")
    addNewStationWindow.buttons["Ok"].click()
    
    XCTAssertEqual("A new name", cells.staticTexts["NameCell"].value as! String)
  }
  
  func testAddStationWithOptionalsBlank() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    stationsWindow.buttons["Add New Station..."].click()
    
    let addNewStationWindow = stationsWindow.sheets["StationDetailSheet"]
    addNewStationWindow.textFields["UrlTextField"].typeText("example.com/station.mp3\t")
    addNewStationWindow.textFields["NameTextField"].typeText("A station name")
    addNewStationWindow.buttons["Ok"].click()
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
  }
  
  func testEditStationWithOptionalsBlank() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    stationsWindow.buttons["Add New Station..."].click()
    
    let addNewStationWindow = stationsWindow.sheets["StationDetailSheet"]
    addNewStationWindow.textFields["UrlTextField"].typeText("example.com/station.mp3\t")
    addNewStationWindow.textFields["NameTextField"].typeText("A station name")
    addNewStationWindow.buttons["Ok"].click()
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
    
    stationsWindow.buttons["Edit..."].click()
    clearTextField(addNewStationWindow.textFields["NameTextField"])
    addNewStationWindow.textFields["NameTextField"].typeText("A new name")
    addNewStationWindow.buttons["Ok"].click()
    
    let cells = table.tableRows.element(boundBy: 0).cells
    XCTAssertEqual("A new name", cells.staticTexts["NameCell"].value as! String)
  }
  
  func testDeleteAStation() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertFalse(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A station name")
    addNewStation(stationName: "A second station name")
    
    let tableRows = stationsWindow.tables["StationsTable"].tableRows
    XCTAssertEqual(2, tableRows.count)
    tableRows.element(boundBy: 1).click()
    stationsWindow.buttons["DeleteBtn"].click()
    
    XCTAssertTrue(app.sheets["alert"].buttons["Ok"].exists)
    XCTAssertTrue(app.sheets["alert"].buttons["Cancel"].exists)
    
    app.sheets["alert"].buttons["Ok"].click()
    XCTAssertEqual(1, tableRows.count)
  }
  
  func testCancelDeleteAStation() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertFalse(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A station name")
    addNewStation(stationName: "A second station name")
    
    let tableRows = stationsWindow.tables["StationsTable"].tableRows
    XCTAssertEqual(2, tableRows.count)
    tableRows.element(boundBy: 1).click()
    stationsWindow.buttons["DeleteBtn"].click()
    
    XCTAssertTrue(app.sheets["alert"].buttons["Ok"].exists)
    XCTAssertTrue(app.sheets["alert"].buttons["Cancel"].exists)
    
    app.sheets["alert"].buttons["Cancel"].click()
    XCTAssertEqual(2, tableRows.count)
  }
  
  func testAddTwoNewStations() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertFalse(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A station name")
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(1, table.tableRows.count)
    
    let cells = table.tableRows.element(boundBy: 0).cells
    XCTAssertEqual("A station name", cells.staticTexts["NameCell"].value as! String)
    XCTAssertEqual("A station description", cells.staticTexts["DescriptionCell"].value as! String)
    XCTAssertEqual("A station city", cells.staticTexts["CityCell"].value as! String)
    XCTAssertEqual("A station country", cells.staticTexts["CountryCell"].value as! String)
    
    XCTAssertTrue(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A second station name")
    XCTAssertEqual(2, table.tableRows.count)
    table.tableRows.element(boundBy: 1).click()
    
    XCTAssertTrue(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertTrue(stationsWindow.buttons["DeleteBtn"].isEnabled)
  }
  
  func testStationSearch() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    
    addNewStation(stationName: "A station name")
    addNewStation(stationName: "A very different thing")
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(2, table.tableRows.count)
    
    stationsWindow.searchFields["SearchField"].typeText("different")
    XCTAssertEqual(1, table.tableRows.count)
    
    // clear search
    stationsWindow.searchFields["SearchField"].buttons["cancel"].click()
    XCTAssertEqual(2, table.tableRows.count)
  }
  
  func testCancelAddNewStationDialog() {
    menuBarsQuery?.menuItems["Preferences"].click()
    
    let stationsWindow = app.windows["Stations"]
    XCTAssertFalse(stationsWindow.buttons["PlayBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["EditBtn"].isEnabled)
    XCTAssertFalse(stationsWindow.buttons["DeleteBtn"].isEnabled)
    
    addNewStation(stationName: "A station name", cancel: true)
    
    let table = stationsWindow.tables["StationsTable"]
    XCTAssertEqual(0, table.tableRows.count)
  }
  
  // MARK: - Private
  
  private func addNewStation(stationName: String, cancel: Bool = false) {
    let stationsWindow = app.windows["Stations"]
    stationsWindow.buttons["AddNewStationBtn"].click()
    let addNewStationWindow = stationsWindow.sheets["StationDetailSheet"]
    
    addNewStationWindow.textFields["UrlTextField"].typeText("example.com/station.mp3\t")
    addNewStationWindow.textFields["NameTextField"].typeText("\(stationName)\t")
    addNewStationWindow.textFields["DescriptionTextField"].typeText("A station description\t")
    addNewStationWindow.textFields["CityTextField"].typeText("A station city\t")
    addNewStationWindow.textFields["CountryTextField"].typeText("A station country")
    
    if cancel {
      addNewStationWindow.buttons["Cancel"].click()
    } else {
      addNewStationWindow.buttons["Ok"].click()
    }
  }
}
