//
//  FetchRecordZoneChangesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 31/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class FetchRecordZoneChangesOperation: CKFetchRecordZoneChangesOperation {
  
  // MARK: - Properties
  
  var changedRecords: [CKRecord] = []
  var deletedRecordIDs: [CKRecord.ID] = []
  
  // MARK: - Lifecycle
  
  override func main() {
    if let count = optionsByRecordZoneID?.count {
      os_log("FetchRecordZoneChangesOperation started for %i zone(s).", log: CloudKitLog, count)
    }
    
    setOperationBlocks()
    super.main()
  }
    
  // MARK: - Private
  
  private func setOperationBlocks() {
    recordChangedBlock = { [unowned self] (record: CKRecord) -> Void in
      os_log("FetchRecordZoneChangesOperation record changed: %@", log: CloudKitLog, record.recordID.recordName)
      self.changedRecords.append(record)
    }
    
    recordWithIDWasDeletedBlock = { [unowned self] (recordID: CKRecord.ID, recordType: String) -> Void in
      os_log("FetchRecordZoneChangesOperation record deleted: %@", log: CloudKitLog, recordID.recordName)
      self.deletedRecordIDs.append(recordID)
    }
    
    recordZoneFetchCompletionBlock = { [unowned self] (recordZoneID: CKRecordZone.ID, serverChangeToken: CKServerChangeToken?, clientChangeTokenData: Data?, _: Bool, error: Error?) -> Void in
      if let error = error {
        os_log("FetchRecordZoneChangesOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let database = self.database {
        os_log("FetchRecordZoneChangesOperation new server change token received for database (type=%i).", log: CloudKitLog, database.databaseScope.rawValue)
        recordZoneID.lastUsedChangeToken = serverChangeToken
        os_log("FetchRecordZoneChangesOperation for database (type=%i) finished.", log: CloudKitLog, database.databaseScope.rawValue)
      }
    }
  }
}
