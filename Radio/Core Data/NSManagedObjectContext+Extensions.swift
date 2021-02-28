//
//  NSManagedObjectContext+Extensions.swift
//  Radio
//
//  Created by Damien Glancy on 19/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import os.log

extension NSManagedObjectContext {
    
  // MARK: - Save Functions
  
  func saveOrRollback(updateCloudKit: Bool = true) -> Bool {
    guard hasChanges else {
      return false
    }
    
    insertedObjects.union(updatedObjects).compactMap { $0 as? BaseMO }.forEach { baseManagedObject in
      baseManagedObject.updateProperties()
    }
    
    let insertedObjectsCopy = insertedObjects
    let modifiedObjectsCopy = updatedObjects
    let deletedRecordIDs = deletedObjects.compactMap { ($0 as? BaseCKRecordMO)?.cloudKitRecordID() }
    
    do {
      try save()
      os_log("Changes saved.", log: CoreDataLog)
      
      if updateCloudKit {
        os_log("Updating CloudKit.", log: CoreDataLog)
        let insertedManagedObjectIDs = insertedObjectsCopy.compactMap { $0.objectID }
        let modifiedManagedObjectIDs = modifiedObjectsCopy.compactMap { $0.objectID }
        CloudKit.shared.saveChangesToCloudKit(insertedManagedObjectIDs: insertedManagedObjectIDs, modifiedManagedObjectIDs: modifiedManagedObjectIDs, deletedRecordIDs: deletedRecordIDs)
        os_log("Updated CloudKit.", log: CoreDataLog)
      }
      
      return true
    } catch {
      rollback()
      os_log("Rollback with error: %@", log: CoreDataLog, error.localizedDescription)
      return false
    }
  }

  public func performChangesAndWait(updateCloudKit: Bool = true, block: @escaping () -> Void) {
    performAndWait {
      block()
      _ = self.saveOrRollback(updateCloudKit: updateCloudKit)
    }
  }
}
