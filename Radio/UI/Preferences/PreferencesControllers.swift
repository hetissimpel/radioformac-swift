//
//  PreferencesControllers.swift
//  Radio
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Cocoa

// MARK: - Window Controller

final class PreferencesWindowController: NSWindowController {
  
  // MARK: - Lifecycle
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    if let window = self.window {
      window.center()
      window.makeKeyAndOrderFront(nil)
    }
    
    NSApp.activate(ignoringOtherApps: true)
  }
}

// MARK: - View Controller

class PreferencesViewController: NSTabViewController {
  
  // MARK: - Lifecycle
  
  override func viewWillAppear() {
    super.viewWillAppear()
    if let window = self.view.window {
      let defaultTabItem = self.tabViewItems[self.selectedTabViewItemIndex]
      window.title = defaultTabItem.label
      setToRegularActivationPolicy()
    }
  }
  
  override func viewDidDisappear() {
    super.viewDidDisappear()
    setToAccessoryActivationPolicy()
  }
  
  // MARK: - Tab bar
  
  override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
    super.tabView(tabView, didSelect: tabViewItem)
    
    if let window = self.view.window {
      window.title = (tabViewItem?.label)!
    }
  }
  
  // MARK: - Activation Policies
  
  private func setToRegularActivationPolicy() {
    NSApp.setActivationPolicy(.regular)
  }
  
  private func setToAccessoryActivationPolicy() {
    NSApp.setActivationPolicy(.accessory)
  }
}

// MARK: - Protocols

protocol CoreDataBackedViewController {
  var managedObjectContext: NSManagedObjectContext { get }
}

