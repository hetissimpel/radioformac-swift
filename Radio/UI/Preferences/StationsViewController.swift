//
//  StationsViewController.swift
//  Radio
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Cocoa
import os.log

// MARK: - Common Predicates

let kAllStationsSearchTemplatePredicate = NSPredicate(format: "((name contains[cd] $SearchString) or (desc contains[cd] $SearchString) or (city contains[cd] $SearchString) or (country contains[cd] $SearchString)) and isSoftDeleted == NO");
let kMyStationsSearchTemplatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [kAllStationsSearchTemplatePredicate, NSPredicate(format: "isUserDefined == YES")]);

// MARK: - StationsViewController

final class StationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate, NSTabViewDelegate, CoreDataBackedViewController, StationDetailSheetDelegate {

  // MARK: - Properties
  
  @IBOutlet weak var tabView: NSTabView!
  @IBOutlet weak var stationsSearchField: NSSearchField!
  @IBOutlet var stationsArrayController: NSArrayController!
  @IBOutlet weak var stationsTableView: NSTableView!
  
  @IBOutlet weak var playBtn: NSButton!
  @IBOutlet weak var editBtn: NSButton!
  @IBOutlet weak var deleteBtn: NSButton!
  @IBOutlet weak var addBtn: NSButton!
  
  @IBOutlet weak var touchBarPlayBtn: NSButton!
  @IBOutlet weak var touchBarEditBtn: NSButton!
  @IBOutlet weak var touchBarDeleteBtn: NSButton!
  @IBOutlet weak var touchBarSearchBtn: NSButton!
  @IBOutlet weak var touchBarAddBtn: NSButton!
  @IBOutlet weak var touchBarUpBtn: NSButton!
  @IBOutlet weak var touchBarDownBtn: NSButton!
  
  @IBOutlet var stationDetailSheetWindow: StationDetailSheetWindow!
  
  @objc dynamic var managedObjectContext = CoreData.shared.persistentContainer.viewContext
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stationDetailSheetWindow.stationDelegate = self
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    try! stationsArrayController.fetch(with: nil, merge: false)
  }
  
  // MARK: - Actions
  
  @IBAction func doubleActionPerformed(_ sender: Any) {
    os_log("Double click performed.", log: UILog)
    
    if let station = stationsArrayController.selectedObjects.first as? Station {
      RadioPlayer.shared.station = station
    }
  }
  
  @IBAction func playBtnPressed(_ sender: Any) {
    os_log("Play station button pressed.", log: UILog)
    
    if let station = stationsArrayController.selectedObjects.first as? Station {
      RadioPlayer.shared.play(station: station)
    }
  }
  
  @IBAction func editBtnPressed(_ sender: Any) {
    os_log("Edit station button pressed.", log: UILog)
    
    if let window = self.view.window, let station = stationsArrayController.selectedObjects.first as? Station {
      stationDetailSheetWindow.station = station
      stationDetailSheetWindow.urlTextField.stringValue = station.url!.absoluteString
      stationDetailSheetWindow.nameTextField.stringValue = station.name!
      stationDetailSheetWindow.descriptionTextField.stringValue = station.desc!
      stationDetailSheetWindow.cityTextField.stringValue = station.city!
      stationDetailSheetWindow.countryTextField.stringValue = station.country!

      window.beginSheet(stationDetailSheetWindow, completionHandler: nil)
    }
  }
  
  @IBAction func deleteBtnPressed(_ sender: Any) {
    os_log("Delete station button pressed.", log: UILog)
    
    if let station = stationsArrayController.selectedObjects.first as? Station {
      if let window = self.view.window {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("Ok", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        alert.messageText = String(format: "\(NSLocalizedString("Delete", comment: "Full string will be Delete 'Station Name'")) %@", station.name ?? kBlankString)
        alert.informativeText = NSLocalizedString("Are you sure you wish to delete this station?", comment: "")
        alert.alertStyle = .warning
        
        alert.beginSheetModal(for: window, completionHandler: { (response) in
          if response == NSApplication.ModalResponse.alertFirstButtonReturn {
//            station.markForCloudKitDelete()
            self.managedObjectContext.delete(station)
             _ = self.managedObjectContext.saveOrRollback()
          }
        })
      }
    }
  }
  
  @IBAction func addBtnPressed(_ sender: Any) {
    os_log("Add station button pressed.", log: UILog)
    
    if let window = self.view.window {
      window.beginSheet(stationDetailSheetWindow, completionHandler: nil)
    }
  }
  
  // MARK: - Touchbar Actions
  
  @IBAction func touchBarPlayBtnPressed(_ sender: Any) {
    playBtnPressed(sender)
  }
  
  @IBAction func touchBarEditBtnPressed(_ sender: Any) {
    editBtnPressed(sender)
  }
  
  @IBAction func touchBarDeleteBtnPressed(_ sender: Any) {
    deleteBtnPressed(sender)
  }

  @IBAction func touchBarSearchBtnPressed(_ sender: Any) {
    stationsSearchField.becomeFirstResponder()
  }
  
  @IBAction func touchBarUpBtnPressed(_ sender: Any) {
    stationsTableView.selectRowIndexes(IndexSet(integer: stationsTableView.selectedRow - 1), byExtendingSelection: false)
  }
  
  @IBAction func touchBarDownBtnPressed(_ sender: Any) {
    stationsTableView.selectRowIndexes(IndexSet(integer: stationsTableView.selectedRow + 1), byExtendingSelection: false)
  }
  
  @IBAction func touchBarAddBtnPressed(_ sender: Any) {
    addBtnPressed(sender)
  }
  
  // MARK: - Array Controller
  
  private func filterPredicateForSelectedTab() -> NSPredicate? {
    guard let tabViewItem = tabView.selectedTabViewItem, let tabViewItemIdentifier = tabViewItem.identifier as? String else {
      return nil
    }
    
    if tabViewItemIdentifier == "AllStationsTabViewItem" {
      return stationsSearchField.stringValue.isEmpty ? nil : kAllStationsSearchTemplatePredicate.withSubstitutionVariables(["SearchString": stationsSearchField.stringValue])
    } else if tabViewItemIdentifier == "MyStationsTabViewItem" {
      return stationsSearchField.stringValue.isEmpty ? NSPredicate(format: "isUserDefined == YES") : kMyStationsSearchTemplatePredicate.withSubstitutionVariables(["SearchString": stationsSearchField.stringValue])
    }
    
    return nil
  }
  
  // MARK: - Stations Table
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    handleTouchBarNavigationBtns()
    
    if let station = stationsArrayController.selectedObjects.first as? Station {
      playBtn.isEnabled = true
      touchBarPlayBtn.isEnabled = true
      
      if station.isUserDefined {
        editBtn.isEnabled = true
        deleteBtn.isEnabled = true
        
        touchBarEditBtn.isEnabled = true
        touchBarDeleteBtn.isEnabled = true
      } else {
        editBtn.isEnabled = false
        deleteBtn.isEnabled = false
        
        touchBarEditBtn.isEnabled = false
        touchBarDeleteBtn.isEnabled = false
      }
    }
  }
  
  private func handleTouchBarNavigationBtns() {
    let selectedRow = stationsTableView.selectedRow
    let totalRows = stationsTableView.numberOfRows
    
    if selectedRow > -1 {
      if selectedRow == 0 && selectedRow == totalRows - 1 { // only one row
        touchBarUpBtn.isEnabled = false
        touchBarDownBtn.isEnabled = false
      } else if selectedRow == 0 { // first rown
        touchBarUpBtn.isEnabled = false
        touchBarDownBtn.isEnabled = true
      } else if selectedRow == totalRows - 1 { // last row
        touchBarUpBtn.isEnabled = true
        touchBarDownBtn.isEnabled = false
      } else {
        touchBarUpBtn.isEnabled = true
        touchBarDownBtn.isEnabled = true
      }
    }
  }
  
  // MARK: -  Search Field Delegate
  
  func searchFieldDidStartSearching(_ sender: NSSearchField) {
    stationsArrayController.filterPredicate = filterPredicateForSelectedTab()
  }

  func searchFieldDidEndSearching(_ sender: NSSearchField) {
    stationsArrayController.filterPredicate = filterPredicateForSelectedTab()
  }
  
  // MARK: - Station Detail Sheet Delegate

  func stationDetailSheetWantsToDismiss() {
    view.window?.endSheet(stationDetailSheetWindow)
  }
  
  // MARK: - Tab Vew Delegates
  
  func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
    stationsArrayController.filterPredicate = filterPredicateForSelectedTab()
    stationsTableView.reloadData()
  }
}

// MARK: -  Delegate Protocols

protocol StationDetailSheetDelegate {
  func stationDetailSheetWantsToDismiss()
}

// MARK: - Station Detail Sheet Window

class StationDetailSheetWindow: NSWindow {
  
  // MARK: - Properties
  
  var station: Station?
  var stationDelegate: StationDetailSheetDelegate?
  
  @IBOutlet weak var urlTextField: NSTextField!
  @IBOutlet weak var nameTextField: NSTextField!
  @IBOutlet weak var descriptionTextField: NSTextField!
  @IBOutlet weak var cityTextField: NSTextField!
  @IBOutlet weak var countryTextField: NSTextField!
  
  // MARK: - Actions
  
  @IBAction func okayBtnPressed(_ sender: Any) {
    os_log("Ok button pressed on station detail sheet.", log: UILog)
    
`    if urlTextField.stringValue.isEmpty || nameTextField.stringValue.isEmpty {
      return
    }`
    
    if let station = station == nil ? Station(context: CoreData.shared.persistentContainer.viewContext) : station {
      station.url = URL(string: urlTextField.stringValue)
      station.name = nameTextField.stringValue
      station.desc = descriptionTextField.stringValue
      station.city = cityTextField.stringValue
      station.country = countryTextField.stringValue
      station.isUserDefined = true
      
      _ = station.managedObjectContext?.saveOrRollback()
    }
    dismissDetailSheet()
  }
  
  @IBAction func cancelBtnPressed(_ sender: Any) {
    os_log("Cancel button pressed on station detail sheet.", log: UILog)
    dismissDetailSheet()
  }
  
  // MARK: - Private
  
  private func dismissDetailSheet() {
    urlTextField.stringValue = kBlankString
    nameTextField.stringValue = kBlankString
    descriptionTextField.stringValue = kBlankString
    cityTextField.stringValue = kBlankString
    countryTextField.stringValue = kBlankString
    urlTextField.becomeFirstResponder()
    station = nil

    stationDelegate?.stationDetailSheetWantsToDismiss()
  }
}
