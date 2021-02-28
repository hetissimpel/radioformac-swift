//
//  CloudKit+PrivateDB.swift
//  Radio
//
//  Created by Damien Glancy on 26/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

extension CloudKit {
  
  // MARK: - Record Zones
  
  func setupZonesOperations() -> Operation {
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))

    let fetchRecordZonesOperation = FetchRecordZonesOperation.fetchAllRecordZonesOperation()
    fetchRecordZonesOperation.database = CKContainer.default().privateCloudDatabase
    
    let processRecordZoneOperation = ProcessRecordZonesOperation()
    let modifyRecordZonesOperation = ModifyRecordZonesOperation()
    
    let transferFetchedZonesOperation = BlockOperation() {
      [unowned fetchRecordZonesOperation, unowned processRecordZoneOperation] in
      
      if let fetchedRecordZones = fetchRecordZonesOperation.fetchedRecordZones {
        processRecordZoneOperation.preProcessRecordZoneIDs = Array(fetchedRecordZones.keys)
      }
    }
    
    let transferProcessedZonesOperation = BlockOperation() {
      [unowned modifyRecordZonesOperation, unowned processRecordZoneOperation] in
      
      modifyRecordZonesOperation.recordZonesToSave = processRecordZoneOperation.postProcessRecordZonesToCreate
      modifyRecordZonesOperation.recordZoneIDsToDelete = processRecordZoneOperation.postProcessRecordZoneIDsToDelete
    }
    
    transferFetchedZonesOperation.addDependency(fetchRecordZonesOperation)
    processRecordZoneOperation.addDependency(transferFetchedZonesOperation)
    transferProcessedZonesOperation.addDependency(processRecordZoneOperation)
    modifyRecordZonesOperation.addDependency(transferProcessedZonesOperation)
    activityOperation.addDependency(modifyRecordZonesOperation)
    
    operationsQueue.addOperations([fetchRecordZonesOperation, transferFetchedZonesOperation, processRecordZoneOperation, transferProcessedZonesOperation, modifyRecordZonesOperation], waitUntilFinished: false)
    
    return activityOperation
  }
  
  // MARK: - Subscriptions
  
  func setupPrivateDatabaseSubscriptions() {
    let database = CKContainer.default().privateCloudDatabase
    
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))
    
    let fetchDatabaseSubscriptionsOperation = FetchDatabaseSubscriptionsOperation.fetchAllSubscriptionsOperation()
    fetchDatabaseSubscriptionsOperation.database = database
    
    let processDatabaseSubscriptionsOperation = ProcessDatabaseSubscriptionsOperation()
    processDatabaseSubscriptionsOperation.querySubscriptionOptions = [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
    
    let modifyDatabaseSubscriptionsOperation = ModifySubscriptionsOperation()
    modifyDatabaseSubscriptionsOperation.database = database
    
    let transferFetchedDatabaseScbscriptionOperation = BlockOperation() { [unowned fetchDatabaseSubscriptionsOperation, unowned processDatabaseSubscriptionsOperation] in
      if let fetchedDatabaseSubscriptions = fetchDatabaseSubscriptionsOperation.fetchedDatabaseSubscriptions {
        processDatabaseSubscriptionsOperation.preProcessDatabaseSubscriptions = fetchedDatabaseSubscriptions
      }
    }
    transferFetchedDatabaseScbscriptionOperation.qualityOfService = .utility
    
    let transferProcessedDatabaseSubscriptionsOperation = BlockOperation() { [unowned modifyDatabaseSubscriptionsOperation, unowned processDatabaseSubscriptionsOperation] in
      modifyDatabaseSubscriptionsOperation.subscriptionsToSave = processDatabaseSubscriptionsOperation.postProcessDatabaseSubscriptionsToCreate
      modifyDatabaseSubscriptionsOperation.subscriptionIDsToDelete = processDatabaseSubscriptionsOperation.postProcessDatabaseSubscriptionIDsToDelete
    }
    transferProcessedDatabaseSubscriptionsOperation.qualityOfService = .utility
    
    transferFetchedDatabaseScbscriptionOperation.addDependency(fetchDatabaseSubscriptionsOperation)
    processDatabaseSubscriptionsOperation.addDependency(transferFetchedDatabaseScbscriptionOperation)
    transferProcessedDatabaseSubscriptionsOperation.addDependency(processDatabaseSubscriptionsOperation)
    modifyDatabaseSubscriptionsOperation.addDependency(transferProcessedDatabaseSubscriptionsOperation)
    activityOperation.addDependency(modifyDatabaseSubscriptionsOperation)
    
    operationsQueue.addOperations([fetchDatabaseSubscriptionsOperation, processDatabaseSubscriptionsOperation, modifyDatabaseSubscriptionsOperation, transferFetchedDatabaseScbscriptionOperation, transferProcessedDatabaseSubscriptionsOperation, activityOperation], waitUntilFinished: false)
  }
  
  // MARK: - Local Core Data changes
  
  func saveChangesToCloudKit(insertedManagedObjectIDs: [NSManagedObjectID], modifiedManagedObjectIDs: [NSManagedObjectID], deletedRecordIDs: [CKRecord.ID]) {
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))
    
    let createRecordsForNewObjectsOperation = CreateRecordsForNewObjectsOperation(insertedManagedObjectIDs: insertedManagedObjectIDs)
    let fetchModifiedRecordsOperation = FetchRecordsForModifiedObjectsOperation(modifiedManagedObjectIDs: modifiedManagedObjectIDs)
    let modifyRecordsOperation = ModifyRecordsFromManagedObjectsOperation(modifiedManagedObjectIDs: modifiedManagedObjectIDs, deletedRecordIDs: deletedRecordIDs)

    let transferCreatedRecordsOperation = BlockOperation() { [unowned modifyRecordsOperation, unowned createRecordsForNewObjectsOperation] in
      modifyRecordsOperation.recordsToSave = createRecordsForNewObjectsOperation.createdRecords
    }
    transferCreatedRecordsOperation.qualityOfService = .utility
    
    let transferFetchedRecordsOperation = BlockOperation() { [unowned modifyRecordsOperation, unowned fetchModifiedRecordsOperation] in
      modifyRecordsOperation.fetchedRecordsToModify = fetchModifiedRecordsOperation.fetchedRecords
    }
    transferFetchedRecordsOperation.qualityOfService = .utility
    
    transferCreatedRecordsOperation.addDependency(createRecordsForNewObjectsOperation)
    transferFetchedRecordsOperation.addDependency(fetchModifiedRecordsOperation)
    modifyRecordsOperation.addDependency(transferCreatedRecordsOperation)
    modifyRecordsOperation.addDependency(transferFetchedRecordsOperation)
    activityOperation.addDependency(modifyRecordsOperation)
    
    operationsQueue.addOperations([createRecordsForNewObjectsOperation, fetchModifiedRecordsOperation, modifyRecordsOperation, transferCreatedRecordsOperation, transferFetchedRecordsOperation, activityOperation], waitUntilFinished: false)
  }
  
  // MARK: - Handle database changes
  
  func handlePrivateDatabaseChanges() -> Operation {
    let database = CKContainer.default().privateCloudDatabase
    
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))

    let fetchDatabaseChangesOperation = FetchDatabaseChangesOperation(database: database)   
  
    let fetchRecordZoneChangesOperation = FetchRecordZoneChangesOperation()
    fetchRecordZoneChangesOperation.database = database
    
    let transferZonesToFetchRecordChangesZoneOperation = BlockOperation { [unowned fetchDatabaseChangesOperation, unowned fetchRecordZoneChangesOperation] in
      fetchRecordZoneChangesOperation.recordZoneIDs = fetchDatabaseChangesOperation.changedRecordsZoneIDs + fetchDatabaseChangesOperation.deletedRecordsZoneIDs
    }
    transferZonesToFetchRecordChangesZoneOperation.qualityOfService = .utility
    
    let processSyncChangesOperation = ProcessSyncChangesOperation()

    let transferDataToProcessSyncChangesOperation = BlockOperation { [unowned processSyncChangesOperation, unowned fetchDatabaseChangesOperation, unowned fetchRecordZoneChangesOperation] in
      //      processSyncChangesOperation.preProcessLocalChangedObjectIDs.append(fetchDatabaseChangesOperation.updatedManagedObjects)
      
      processSyncChangesOperation.preProcessServerChangedRecords.append(contentsOf: fetchRecordZoneChangesOperation.changedRecords)
      processSyncChangesOperation.preProcessServerDeletedRecordIDs.append(contentsOf: fetchRecordZoneChangesOperation.deletedRecordIDs)
    }

    transferZonesToFetchRecordChangesZoneOperation.addDependency(fetchDatabaseChangesOperation)
    fetchRecordZoneChangesOperation.addDependency(transferZonesToFetchRecordChangesZoneOperation)
    transferDataToProcessSyncChangesOperation.addDependency(fetchRecordZoneChangesOperation)
    processSyncChangesOperation.addDependency(transferDataToProcessSyncChangesOperation)
    activityOperation.addDependency(processSyncChangesOperation)
    
    operationsQueue.addOperations([fetchDatabaseChangesOperation, fetchRecordZoneChangesOperation, transferZonesToFetchRecordChangesZoneOperation, processSyncChangesOperation, transferDataToProcessSyncChangesOperation], waitUntilFinished: false)
    
    return activityOperation
  }
}
