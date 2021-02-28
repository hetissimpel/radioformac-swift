//
//  ModifyRecordsFromManagedObjectsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 30/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import os.log

final class ModifyRecordsFromManagedObjectsOperation: CKModifyRecordsOperation {

  // MARK: - Properties
  
  var fetchedRecordsToModify: [CKRecord.ID : CKRecord]?
  private let modifiedManagedObjectIDs: [NSManagedObjectID]

  // MARK: - Lifecycle
  
  init(modifiedManagedObjectIDs: [NSManagedObjectID] = [], deletedRecordIDs: [CKRecord.ID] = []) {
    self.modifiedManagedObjectIDs = modifiedManagedObjectIDs
    super.init()
    self.recordsToSave = []
    self.recordIDsToDelete = deletedRecordIDs
    self.savePolicy = .changedKeys
  }
  
  override func main() {
    os_log("ModifyRecordsFromManagedObjectsOperation started.", log: CloudKitLog)
    
    setOperationBlocks()
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) {
      self.recordsToSave!.append(contentsOf: self.modifiedManagedObjectIDs.map { try? context.existingObject(with: $0) as? BaseCKRecordMO }.compactMap { $0?.cloudKitRecord() })
      
      os_log("ModifyRecordsFromManagedObjectsOperation.recordsToSave: %i record(s)", log: CloudKitLog, self.recordsToSave!.count)
      os_log("ModifyRecordsFromManagedObjectsOperation.recordIDsToDelete: %i record(s)", log: CloudKitLog, self.recordIDsToDelete!.count)
    }
    
    super.main()
    
    os_log("ModifyRecordsFromManagedObjectsOperation finished.", log: CloudKitLog)
  }
  
  // MARK: - Private functions
  
  private func setOperationBlocks() {
    perRecordCompletionBlock = { (record: CKRecord, error: Error?) -> Void in
      if let error = error {
        os_log("ModifyRecordsFromManagedObjectsOperation.perRecordCompletionBlock error: %@.", log: CloudKitLog, error.localizedDescription)
      } else {
        os_log("Record modification successful for recordID: %@.", log: CloudKitLog, record.recordID)
      }
    }
    
    modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecord.ID]?, error: Error?) -> Void in
      
      if let error = error {
        os_log("ModifyRecordsFromManagedObjectsOperation.modifyRecordsCompletionBlock error: %@.", log: CloudKitLog, error.localizedDescription)
      } else if let deletedRecords = deletedRecords {
        for recordID in deletedRecords {
          os_log("Record deletion successful for recordID: %@.", log: CloudKitLog, recordID)
        }
      }
      //self.cloudKitManager.lastCloudKitSyncTimestamp = Date()
    }
    
  }
}
