//
//  CreateRecordsForNewObjectsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 30/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import os.log

final class CreateRecordsForNewObjectsOperation: Operation {
  
  // MARK: - Properties
  
  var createdRecords: [CKRecord] = []
  private let insertedManagedObjectIDs: [NSManagedObjectID]

  // MARK: - Lifecycle
  
  init(insertedManagedObjectIDs: [NSManagedObjectID]) {
    self.insertedManagedObjectIDs = insertedManagedObjectIDs
    super.init()
  }
  
  override func main() {
    super.main()
    os_log("CreateRecordsForNewObjectsOperation started.", log: CoreDataLog)
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) {
      self.createdRecords = self.insertedManagedObjectIDs.map { try? context.existingObject(with: $0) as? BaseCKRecordMO}.compactMap { $0?.cloudKitRecord() }
    }
    
    os_log("CreateRecordsForNewObjectsOperation finished; created %i new CKRecord(s)", log: CoreDataLog, self.createdRecords.count)
  }
}
