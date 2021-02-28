//
//  StatusMenuController.swift
//  Radio
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import Cocoa
import os.log

final class StatusMenuController: NSObject, NSMenuDelegate {
  
  // MARK: - Properties
  
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var radioDisplayViewController: RadioDisplayViewController!
  
  var menuAnimation: MenuAnimation?
  
  lazy var preferencesWindowController: PreferencesWindowController = {
    return NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "PreferencesWindowController") as! PreferencesWindowController
  }()
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupDefaultStatusMenuImages()
    
    statusItem.isVisible = true
    statusItem.behavior = .terminationOnRemoval
    statusItem.autosaveName = kAppBundleId
    statusItem.menu = statusMenu
  }
  
  // MARK: - Actions
  
  @IBAction func preferencesBtnPressed(_ sender: Any) {
    os_log("Preferences button pressed.", log: UILog)
    preferencesWindowController.showWindow(sender)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  @IBAction func quitBtnPressed(_ sender: Any) {
    os_log("Quit button pressed.", log: UILog)
    NSApp.terminate(sender)
  }
  
  // MARK: - Animations
  
  func startMenuAnimation() {
    os_log("Starting Status Menu Item animations.", log: UILog)
    
    if menuAnimation == nil {
      menuAnimation = MenuAnimation(statusItem: statusItem)
    }
    
    menuAnimation?.start()
  }
  
  func stopMenuAnimation() {
    os_log("Stopping Status Menu Item animations.", log: UILog)
    menuAnimation?.stop()
    setupDefaultStatusMenuImages()
  }
  
  // MARK: - Menu Delegate

  public func menuWillOpen(_ menu: NSMenu) {
    radioDisplayViewController.viewWillAppear()
  }
  
  public func menuDidClose(_ menu: NSMenu) {
    radioDisplayViewController.viewDidDisappear()
  }
  
  // MARK: - UI
  
  private func setupDefaultStatusMenuImages() {
    if let button = statusItem.button {
      button.image = NSImage(named: "menubar_icon_default")
      button.image?.isTemplate = true
      
      button.alternateImage = NSImage(named: "menubar_icon_selected")
      button.alternateImage?.isTemplate = true
    }
  }
}

// MARK: - Menu Animation

class MenuAnimation {
  
  // MARK: - Properties
  
  let kNumberOfAnimationFramesAvailable = 3
  let kFirstFrameIndex = 1
  
  private var statusItem: NSStatusItem
  private var timer: Timer?
  private var currentImageFrameIndex: Int = 0
  
  // MARK: - Lifecycle

  init(statusItem: NSStatusItem) {
    self.statusItem = statusItem
  }
  
  deinit {
    stop()
  }
  
  // MARK: - Functions
  
  func start() {
    if timer?.isValid ?? false {
      return
    }
    
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
      let targetImageFrameIndex: Int = {
          if self.currentImageFrameIndex == self.kNumberOfAnimationFramesAvailable {
            self.currentImageFrameIndex = self.kFirstFrameIndex
          } else {
            self.currentImageFrameIndex = self.currentImageFrameIndex + 1
          }
          
          return self.currentImageFrameIndex
      }()
      
      if let button = self.statusItem.button {
        button.image = NSImage(named: "menubar_icon_default_anim_\(targetImageFrameIndex)")
        button.image?.isTemplate = true
        button.alternateImage = NSImage(named: "menubar_icon_selected_anim_\(targetImageFrameIndex)")
        button.alternateImage?.isTemplate = true
      }
    })
  }
  
  func stop() {
    timer?.invalidate()
    timer = nil
    currentImageFrameIndex = 0
  }
}
