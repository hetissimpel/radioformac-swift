//
//  FetchStationRecordsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 11/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class FetchStationRecordsOperation: CKQueryOperation {

  // MARK: - Properties
  
  private var fetchedStationsCompletionBlock: (([CKRecord]) -> Void)?
  private var stationRecords: [CKRecord] = []

  // MARK: - Lifecycle
  
  init(database: CKDatabase, since timestamp: Date, _ fetchedStationsCompletionBlock: (([CKRecord]) -> Void)? = nil) {
    super.init()
    self.database = database
    self.fetchedStationsCompletionBlock = fetchedStationsCompletionBlock
    self.query = CKQuery(recordType: "Station", predicate: NSPredicate(format: "modificationDate > %@", timestamp as NSDate))
  }
  
  override func main() {
    os_log("FetchStationRecordsOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private
  
  private func setOperationBlocks() {
    recordFetchedBlock = { [unowned self] (record: CKRecord) in
      self.stationRecords.append(record)
    }
    
    queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) in
      if let error = error {
        os_log("FetchStationRecordsOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
    os_log("FetchStationRecordsOperation fetched: %i record(s).", log: CloudKitLog, self.stationRecords.count)
      
      if let cursor = cursor {
        os_log("FetchStationRecordsOperation cursor available; querying next batch.", log: CloudKitLog)
        
        let operation = CKQueryOperation(cursor: cursor)
        operation.recordFetchedBlock = self.recordFetchedBlock
        operation.queryCompletionBlock = self.queryCompletionBlock
        self.database?.add(operation)
      } else {
        if let fetchedStationsCompletionBlock = self.fetchedStationsCompletionBlock {
          DispatchQueue.main.async {
            fetchedStationsCompletionBlock(self.stationRecords)
          }
        }
      }
    }
  }
}
