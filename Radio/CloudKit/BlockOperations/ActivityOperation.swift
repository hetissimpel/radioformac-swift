//
//  ActivityOperation.swift
//  Radio
//
//  Created by Damien Glancy on 17/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import os.log

final class ActivityOperation: BlockOperation {
  
  // MARK: - Properties
  
  let activity: NSObjectProtocol
  let activityUUID: UUID
  
  // MARK: - Lifecycle
  
  init(activity: NSObjectProtocol) {
    self.activity = activity
    self.activityUUID = UUID()
    os_log("ActivityOperation started (UUID: %@).", log: CloudKitLog, activityUUID.uuidString)
  }
  
  override func main() {
    super.main()
    ProcessInfo.processInfo.endActivity(activity)
    os_log("ActivityOperation finished (UUID: %@).", log: CloudKitLog, activityUUID.uuidString)
  }
}
