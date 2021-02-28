//
//  AppDelegate.swift
//  Radio
//
//  Created by Damien Glancy on 06/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Cocoa
import CloudKit
import UserNotifications
import os.log

// MARK: - Application Delegate

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  // MARK: - Properties
  
  private let startupOperationsQueue = OperationQueue()
  
  // MARK: - Lifecycle
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    preventMultipleRadiosFromRunning()

    guard ProcessInfo.processInfo.environment["TEST_MODE"] == nil else {
      runInTestMode()
      setupAudioVolumes()
      return
    }

    setupAudioVolumes()
    setupCloudKit()
    setupPushNotifications()
    
    os_log("Launched.", log: LifecycleLog)
  }
  
  func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
    os_log("Received remote notification.", log: LifecycleLog)
    CloudKit.shared.handleCloudKitNotification(userInfo: userInfo)
  }
  
  // MARK: - Startup
  
  private func preventMultipleRadiosFromRunning() {
    if NSRunningApplication.runningApplications(withBundleIdentifier: kAppBundleId).count > 1 {
      os_log("Radio is already running, terminating this instance.")
      NSApp.terminate(self)
    }
  }
  
  private func setupAudioVolumes() {
    let audioVolumeOperation = BlockOperation() {
      guard let volume = UserDefaults.standard.object(forKey: UserDefaultKeys.CurrentVolume.rawValue) as? Float else {
        os_log("Setting default volume.", log: LifecycleLog)
        setAudioVolume(kDefaultVolume, save: true)
        return
      }
      
      os_log("Setting user preferred volume: %.2f.", log: LifecycleLog, volume)
      setAudioVolume(volume)
      

    }
    audioVolumeOperation.qualityOfService = .userInitiated
    
    let audioMuteOperation = BlockOperation() {
      if UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue) {
        setAudioMuted()
      } else {
        setAudioNotMuted()
      }
    }
    audioMuteOperation.qualityOfService = .userInitiated
    
    startupOperationsQueue.addOperations([audioVolumeOperation, audioMuteOperation], waitUntilFinished: false)
  }
  
  private func setupCloudKit() {
    CloudKit.shared.startOperations()
  }
  
  private func setupPushNotifications() {
    NSApplication.shared.registerForRemoteNotifications(matching: .badge)
  }
  
  // MARK: - Test Support
  
  private func runInTestMode() {
    os_log("Running in test mode.", log: LifecycleLog)
    UserDefaults.standard.removePersistentDomain(forName: kAppBundleId)
    UserDefaults.standard.synchronize()
    CoreData.shared.destroyPersistentContainerAndStore()
  }
}

// MARK: - Custom Radio Application

class RadioApplication: NSApplication {
  let strongDelegate = AppDelegate()
  
  override init() {
    super.init()
    self.delegate = strongDelegate
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
