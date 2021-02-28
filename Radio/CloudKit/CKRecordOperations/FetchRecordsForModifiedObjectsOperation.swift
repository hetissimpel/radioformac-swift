//
//  FetchRecordsForModifiedObjectsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 30/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class FetchRecordsForModifiedObjectsOperation: CKFetchRecordsOperation {

  // MARK: - Properties
  
  var fetchedRecords: [CKRecord.ID : CKRecord]?
  private let modifiedManagedObjectIDs: [NSManagedObjectID]

  // MARK: - Lifecycle
  
  init(modifiedManagedObjectIDs: [NSManagedObjectID] = []) {
    self.modifiedManagedObjectIDs = modifiedManagedObjectIDs
    super.init()
  }
  
  override func main() {
    os_log("FetchRecordsForModifiedObjectsOperation started.", log: CloudKitLog)
    setOperationBlocks()
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) {
      self.recordIDs = self.modifiedManagedObjectIDs.map { try? context.existingObject(with: $0) as? BaseCKRecordMO }.compactMap { $0?.cloudKitRecordID() }
    }
    
    super.main()
      os_log("FetchRecordsForModifiedObjectsOperation finished.", log: CloudKitLog)
    }
    
  // MARK: - Private
  
  private func setOperationBlocks() {
    fetchRecordsCompletionBlock = { [unowned self] (fetchedRecords: [CKRecord.ID : CKRecord]?, error: Error?) -> Void in
      if let fetchedRecords = fetchedRecords {
        self.fetchedRecords = fetchedRecords
        os_log("FetchRecordsForModifiedObjectsOperation.fetchRecordsCompletionBlock - fetched: %i record(s)", log: CloudKitLog, fetchedRecords.count)
      }
    }
  }
}
