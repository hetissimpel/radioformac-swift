//
//  FetchRecordsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 17/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class FetchRecordsOperation: CKFetchRecordsOperation {
  
  // MARK: - Properties
  
  var fetchedRecords: [CKRecord] = []
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("FetchRecordsOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private
  
  private func setOperationBlocks() {
    perRecordCompletionBlock = { [unowned self] (record: CKRecord?, recordID: CKRecord.ID?, error: Error?) in
      if let error = error {
        os_log("FetchRecordsOperation for recordID: %@, error: %@.", log: CloudKitLog, recordID?.recordName ?? "<nil>", error.localizedDescription)
      }
      
      if let record = record {
        self.fetchedRecords.append(record)
      }
    }
    
    fetchRecordsCompletionBlock = { (_, error: Error?) in
      if let error = error {
        os_log("FetchRecordsOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      os_log("FetchRecordsOperation fetched: %i record(s).", log: CloudKitLog, self.fetchedRecords.count)
    }
  }
}
