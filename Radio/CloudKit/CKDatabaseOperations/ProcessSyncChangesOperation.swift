//
//  ProcessSyncChangesOperation.swift
//  Radio
//
//  Created by Damien Glancy on 31/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class ProcessSyncChangesOperation: Operation {

  // MARK: - Properties
  
  var preProcessLocalChangedObjectIDs: [NSManagedObjectID] = []
  var preProcessLocalDeletedRecordIDs: [CKRecord.ID] = []
  var preProcessServerChangedRecords: [CKRecord] = []
  var preProcessServerDeletedRecordIDs: [CKRecord.ID] = []
  
  var postProcessChangesToCoreData: [CKRecord] = []
  var postProcessChangesToServer: [CKRecord] = []
  var postProcessDeletesToCoreData: [CKRecord.ID] = []
  var postProcessDeletesToServer: [CKRecord.ID] = []
  
  private var changedBaseObjects: [BaseCKRecordMO] = []
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("ProcessSyncChangesOperation started.", log: CoreDataLog)
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) { [unowned self] in
      self.logPreStats()
      
      self.changedBaseObjects = self.fetchBaseObjects(context: context, managedObjectIDs: self.preProcessLocalChangedObjectIDs)
      
      self.processServerDeletions(context: context)
      self.processLocalDeletions()
      
      self.logPostStats()
    }

    os_log("ProcessSyncChangesOperation finished.", log: CoreDataLog)
  }
  
  // MARK: - Private
  
  private func processServerDeletions(context: NSManagedObjectContext) {
    for deletedServerRecordID in preProcessServerDeletedRecordIDs {
      if let index = changedBaseObjects.firstIndex(where: { $0.recordName == deletedServerRecordID.recordName }) {
        changedBaseObjects.remove(at: index)
      }
      
      postProcessDeletesToCoreData.append(deletedServerRecordID)
    }
  }
  
  private func processLocalDeletions() {
    for deletedLocalRecordID in preProcessLocalDeletedRecordIDs {
      if let index = preProcessServerChangedRecords.firstIndex(where: { $0.recordID.recordName == deletedLocalRecordID.recordName }) {
        preProcessServerChangedRecords.remove(at: index)
      }
      
      postProcessDeletesToServer.append(deletedLocalRecordID)
    }
  }
  
  private func fetchBaseObjects(context: NSManagedObjectContext, managedObjectIDs: [NSManagedObjectID]) -> [BaseCKRecordMO] {
    var baseMOs: [BaseCKRecordMO] = []
    
    for managedObjectID in managedObjectIDs {
      do {
        let managedObject = try context.existingObject(with: managedObjectID)
        
        if let baseMO = managedObject as? BaseCKRecordMO {
          baseMOs.append(baseMO)
        }
      } catch let error as NSError {
        os_log("Fetching error: %@.", log: CoreDataLog, error.localizedDescription)
      }
    }
    
    return baseMOs
  }
  
  // MARK: - Logging
  
  private func logPreStats() {
    os_log("ProcessSyncChangesOperation preProcessLocalChangedObjectIDs: %i records", log: CoreDataLog, self.preProcessLocalChangedObjectIDs.count)
    os_log("ProcessSyncChangesOperation preProcessLocalDeletedRecordIDs: %i records", log: CoreDataLog, self.preProcessLocalDeletedRecordIDs.count)
    os_log("ProcessSyncChangesOperation preProcessServerChangedRecords: %i records", log: CoreDataLog, self.preProcessServerChangedRecords.count)
    os_log("ProcessSyncChangesOperation preProcessServerDeletedRecordIDs: %i records", log: CoreDataLog, self.preProcessServerDeletedRecordIDs.count)
  }
  
  private func logPostStats() {
    os_log("ProcessSyncChangesOperation postProcessChangesToServer: %i records", log: CoreDataLog, self.postProcessChangesToServer.count)
    os_log("ProcessSyncChangesOperation postProcessDeletesToServer: %i records", log: CoreDataLog, self.postProcessDeletesToServer.count)
    os_log("ProcessSyncChangesOperation postProcessChangesToCoreData: %i records", log: CoreDataLog, self.postProcessChangesToCoreData.count)
    os_log("ProcessSyncChangesOperation postProcessDeletesToCoreData: %i records", log: CoreDataLog, self.postProcessDeletesToCoreData.count)
  }
  
}
