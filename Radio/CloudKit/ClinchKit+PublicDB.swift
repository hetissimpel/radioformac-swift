//
//  ClinchKit+PublicDB.swift
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
    
  // MARK: - Subscriptions
  
  func setupPublicDatabaseSubscriptions() {
    let database = CKContainer.default().publicCloudDatabase
    
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .background, reason: "Processing CloudKit notifications"))
    
    let fetchDatabaseSubscriptionsOperation = FetchDatabaseSubscriptionsOperation.fetchAllSubscriptionsOperation()
    fetchDatabaseSubscriptionsOperation.database = database
    
    let processDatabaseSubscriptionOperation = ProcessDatabaseSubscriptionsOperation()
    processDatabaseSubscriptionOperation.querySubscriptionOptions = [.firesOnRecordCreation, .firesOnRecordUpdate]
    
    let transferFetchedDatabaseScbscriptionOperation = BlockOperation() { [unowned fetchDatabaseSubscriptionsOperation, unowned processDatabaseSubscriptionOperation] in
      if let fetchedDatabaseSubscriptions = fetchDatabaseSubscriptionsOperation.fetchedDatabaseSubscriptions {
        processDatabaseSubscriptionOperation.preProcessDatabaseSubscriptions = fetchedDatabaseSubscriptions
      }
    }
    transferFetchedDatabaseScbscriptionOperation.qualityOfService = .utility
    
    let saveDatabaseSubscriptionOperation = BlockOperation() { [unowned processDatabaseSubscriptionOperation] in
      processDatabaseSubscriptionOperation.postProcessDatabaseSubscriptionsToCreate.forEach { subscription in
        database.save(subscription) { (record, error) in
          if let error = error {
            os_log("Database subscription error: %@.", log: CloudKitLog, error.localizedDescription)
          } else {
            os_log("Database subscription created.", log: CloudKitLog)
          }
        }
      }
    }
    saveDatabaseSubscriptionOperation.qualityOfService = .utility
    
    transferFetchedDatabaseScbscriptionOperation.addDependency(fetchDatabaseSubscriptionsOperation)
    processDatabaseSubscriptionOperation.addDependency(transferFetchedDatabaseScbscriptionOperation)
    saveDatabaseSubscriptionOperation.addDependency(processDatabaseSubscriptionOperation)
    activityOperation.addDependency(saveDatabaseSubscriptionOperation)
    
    operationsQueue.addOperations([fetchDatabaseSubscriptionsOperation, transferFetchedDatabaseScbscriptionOperation, processDatabaseSubscriptionOperation, saveDatabaseSubscriptionOperation, activityOperation], waitUntilFinished: false)
  }
  
}
