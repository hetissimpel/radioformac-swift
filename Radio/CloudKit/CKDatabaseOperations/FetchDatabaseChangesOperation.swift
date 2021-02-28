//
//  FetchDatabaseChangesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 31/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class FetchDatabaseChangesOperation: CKFetchDatabaseChangesOperation {

  // MARK: - Properties
  
  var changedRecordsZoneIDs: [CKRecordZone.ID] = []
  var deletedRecordsZoneIDs: [CKRecordZone.ID] = []
  
  // MARK: - Lifecycle
  
  init(database: CKDatabase) {
    super.init()
    
    self.database = database
    if let token = database.lastUsedChangeToken {
      self.previousServerChangeToken = token
    }
  }
  
  override func main() {
    os_log("FetchDatabaseChangesOperation for database (type=%i) started.", log: CloudKitLog, (database?.databaseScope.rawValue)!)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private
  
  private func setOperationBlocks() {
    recordZoneWithIDChangedBlock = { [unowned self] (recordZoneID: CKRecordZone.ID) in
      self.changedRecordsZoneIDs.append(recordZoneID)
    }
    
    recordZoneWithIDWasDeletedBlock = { [unowned self] (recordZoneID: CKRecordZone.ID) in
      self.deletedRecordsZoneIDs.append(recordZoneID)
    }
    
    fetchDatabaseChangesCompletionBlock = { [unowned self] (serverChangeToken: CKServerChangeToken?, _: Bool, error: Error?) in
      if let error = error {
        os_log("FetchDatabaseChangesOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let database = self.database {
        os_log("FetchDatabaseChangesOperation new server change token received for database (type=%i).", log: CloudKitLog, database.databaseScope.rawValue)
        database.lastUsedChangeToken = serverChangeToken
        os_log("FetchDatabaseChangesOperation processed: %i zone(s)", log: CoreDataLog, self.changedRecordsZoneIDs.count + self.deletedRecordsZoneIDs.count)
        os_log("FetchDatabaseChangesOperation for database (type=%i) finished.", log: CloudKitLog, database.databaseScope.rawValue)
      }
    }
  }
  
}
