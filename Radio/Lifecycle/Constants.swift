//
//  Constants.swift
//  Radio
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import os.log

// MARK: - Logging

let LogSubsystem = "nl.hetissimpel.radio"
let LifecycleLog = OSLog(subsystem: LogSubsystem, category: "Lifecycle")
let CloudKitLog = OSLog(subsystem: LogSubsystem, category: "CloudKit")
let CoreDataLog = OSLog(subsystem: LogSubsystem, category: "CoreData")
let AudioLog = OSLog(subsystem: LogSubsystem, category: "Audio")
let UILog = OSLog(subsystem: LogSubsystem, category: "UI")
let ScriptingLog = OSLog(subsystem: LogSubsystem, category: "Scripting")

// MARK: - Static Constants

let kAppName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
let kAppBundleId = Bundle.main.bundleIdentifier!
let kBlankString = ""
let kDefaultVolume = Float(0.5)

// MARK: - User Defaults

enum UserDefaultKeys: String {
  case CurrentVolume = "CurrentVolumeKey"
  case Mute = "MuteKey"
  case CloudKitPublicDatabaseLastSync = "CloudKitPublicDatabaseLastSyncKey"
  case CloudKitPrivateDatabaseInitialSyncPerformed = "CloudKitPrivateDatabaseInitialSyncPerformedKey"
}
