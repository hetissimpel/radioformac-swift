//
//  ProcessRecordZonesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 24/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class ProcessRecordZonesOperation: Operation {
  
  // MARK: - Properties
  
  var preProcessRecordZoneIDs: [CKRecordZone.ID] = []
  var postProcessRecordZonesToCreate: [CKRecordZone] = []
  var postProcessRecordZoneIDsToDelete: [CKRecordZone.ID] = []
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("ProcessRecordZonesOperation started.", log: CloudKitLog)
    setZonesToCreate()
    setZonesToDelete()
    super.main()
    os_log("ProcessRecordZonesOperation finished.", log: CloudKitLog)
  }
  
  // MARK: - Private functions
  
  private func setZonesToCreate() {
    let serverZoneNamesSet = Set(preProcessRecordZoneIDs.map { $0.zoneName})
    let missingZoneNamesSet = Set(CloudKitZone.allCloudKitZoneNames).subtracting(serverZoneNamesSet)
    
    missingZoneNamesSet.forEach { missingZoneName in
      if let missingCloudKitZone = CloudKitZone(rawValue: missingZoneName) {
        let missingRecordZone = CKRecordZone(zoneID: missingCloudKitZone.recordZoneID)
        postProcessRecordZonesToCreate.append(missingRecordZone)
      }
    }
  }
  
  private func setZonesToDelete() {
    for recordZoneID in preProcessRecordZoneIDs where recordZoneID != CKRecordZone.default().zoneID  && (CloudKitZone(rawValue: recordZoneID.zoneName) == nil) {
      postProcessRecordZoneIDsToDelete.append(recordZoneID)
    }
  }
}
