//
//  CloudKit+Notifications.swift
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
  
  // MARK: - Notifications
  
  func handleCloudKitNotification(userInfo: [String : Any]) {
    let notification = CKDatabaseNotification(fromRemoteNotificationDictionary: userInfo)!
    switch notification.databaseScope {
    case .public:
      handleChangeNotification(notification: CKQueryNotification(fromRemoteNotificationDictionary: userInfo)!, database: CKContainer.default().publicCloudDatabase)
    case .private:
      handleChangeNotification(notification: CKQueryNotification(fromRemoteNotificationDictionary: userInfo)!, database: CKContainer.default().privateCloudDatabase)
    default:
      break
    }
  }
  
  private func handleChangeNotification(notification: CKQueryNotification, database: CKDatabase) {
    os_log("Handling public database change notification", log: CloudKitLog)
    
    switch notification.queryNotificationReason {
    case .recordCreated, .recordUpdated:
      handleNewOrUpdatedStation(notification: notification, database: database)
    case .recordDeleted:
      handleDeletedStation(notification: notification)
    @unknown default:
      fatalError("Unknown CloudKit notification received")
    }
  }
  
  private func handleNewOrUpdatedStation(notification: CKQueryNotification, database: CKDatabase) {
    guard let recordID = notification.recordID else {
      return
    }
    
    os_log("Handling new public database station notification", log: CloudKitLog)
    
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))
    
    let fetchCloudKitRecordsOperation = FetchRecordsOperation(recordIDs: [recordID])
    fetchCloudKitRecordsOperation.database = database
    
    let saveChangesToCoreDataOperation = SaveChangedRecordsToCoreDataOperation()
    saveChangesToCoreDataOperation.databaseScope = notification.databaseScope
    
    let transferFetchedRecordsOperation = BlockOperation() { [unowned fetchCloudKitRecordsOperation, unowned saveChangesToCoreDataOperation] in
      saveChangesToCoreDataOperation.changedRecords = fetchCloudKitRecordsOperation.fetchedRecords
    }
    transferFetchedRecordsOperation.qualityOfService = .utility
    
    transferFetchedRecordsOperation.addDependency(fetchCloudKitRecordsOperation)
    saveChangesToCoreDataOperation.addDependency(transferFetchedRecordsOperation)
    activityOperation.addDependency(saveChangesToCoreDataOperation)
    
    operationsQueue.addOperations([fetchCloudKitRecordsOperation, transferFetchedRecordsOperation, saveChangesToCoreDataOperation, activityOperation], waitUntilFinished: false)
  }
  
  private func handleDeletedStation(notification: CKQueryNotification) {
    guard let recordID = notification.recordID else {
      return
    }
    
    os_log("Handling deleted database station notification", log: CloudKitLog)
    
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))
    
    let deletedRecordsToCoreDataOperation = DeletedRecordsToCoreDataOperation()
    deletedRecordsToCoreDataOperation.deletedRecordIDs = [recordID]
    
    activityOperation.addDependency(deletedRecordsToCoreDataOperation)
    
    operationsQueue.addOperations([deletedRecordsToCoreDataOperation, activityOperation], waitUntilFinished: false)
  }
}
