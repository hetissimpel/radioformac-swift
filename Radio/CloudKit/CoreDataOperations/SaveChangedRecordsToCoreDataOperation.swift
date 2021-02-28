//
//  SaveChangedRecordsToCoreDataOperation.swift
//  Radio
//
//  Created by Damien Glancy on 11/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class SaveChangedRecordsToCoreDataOperation: Operation {
  
  // MARK: - Properties
  
  var changedRecords: [CKRecord] = []
  var databaseScope: CKDatabase.Scope?
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("SaveChangedRecordsToCoreDataOperation started.", log: CoreDataLog)
    
    super.main()
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) {
      self.changedRecords.forEach { record in
        let station = Station.findOrCreate(in: context, matching: NSPredicate(format: "recordName == %@", record.recordID.recordName)) { station in
          station.isUserDefined = self.databaseScope == .private ? true : false
        }
        station.updateFromCloud(record: record)
      }      
    }
    
    os_log("SaveChangedRecordsToCoreDataOperation finished.", log: CoreDataLog)
  }
}
