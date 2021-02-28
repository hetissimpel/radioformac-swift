//
//  FetchRecordZonesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 24/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class FetchRecordZonesOperation: CKFetchRecordZonesOperation {
  
  // MARK: - Properties
  
  var fetchedRecordZones: [CKRecordZone.ID : CKRecordZone]?
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("FetchAllRecordZonesOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private functions
  
  private func setOperationBlocks() {
    fetchRecordZonesCompletionBlock = {
      [unowned self]
      (recordZones: [CKRecordZone.ID: CKRecordZone]?, error: Error?) -> Void in
      
      if let error = error {
        os_log("FetchRecordZonesOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let recordZones = recordZones {
        self.fetchedRecordZones = recordZones
        for recordID in recordZones.keys {
          os_log("RecordZone found: %@.", log: CloudKitLog, recordID.zoneName)
        }
      }
      
      os_log("FetchRecordZonesOperation finished.", log: CloudKitLog)
    }
  }
  
}

