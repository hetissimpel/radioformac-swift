//
//  ModifyRecordZonesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 24/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class ModifyRecordZonesOperation: CKModifyRecordZonesOperation {
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("ModifyRecordZonesOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
    os_log("ModifyRecordZonesOperation finished.", log: CloudKitLog)
  }
  
  // MARK: -  Private functions
  
  private func setOperationBlocks() {
    modifyRecordZonesCompletionBlock = {
      (modifiedRecordZones: [CKRecordZone]?, deletedRecordZoneIDs: [CKRecordZone.ID]?, error: Error?) -> Void in
      
      if let error = error {
        os_log("createModifyRecordZoneOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let modifiedRecordZones = modifiedRecordZones {
        for recordZone in modifiedRecordZones {
          os_log("Modified RecordZone: %@.", log: CloudKitLog, recordZone.zoneID.zoneName)
        }
      }
      
      if let deletedRecordZoneIDs = deletedRecordZoneIDs {
        for zoneID in deletedRecordZoneIDs {
          os_log("Deleted ZoneID: %@.", log: CloudKitLog, zoneID.zoneName)
        }
      }
      
    }
  }
}
