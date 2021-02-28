//
//  CloudKit.swift
//  Radio
//
//  Created by Damien Glancy on 11/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class CloudKit {
  
  // MARK: - Singleton
  
  static let shared = CloudKit()
  
  // MARK: - Properties
  
  let operationsQueue = OperationQueue()
  
  var lastPublicDatabaseSyncTimestamp: Date {
    get {
      if let lastCloudKitSyncTimestamp = UserDefaults.standard.object(forKey: UserDefaultKeys.CloudKitPublicDatabaseLastSync.rawValue) as? Date {
        return lastCloudKitSyncTimestamp
      } else {
        return Date.distantPast
      }
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.CloudKitPublicDatabaseLastSync.rawValue)
    }
  }
  
  // MARK: - Lifecycle & Init
  
  private init() {
    self.operationsQueue.name = "CloudKit Operations Queue"
    self.operationsQueue.qualityOfService = .utility
  }
  
  // MARK: - Start Operations
  
  func startOperations() {
    startPublicDatabaseOperations()
    startPrivateDatabaseOperations()
  }
  
  // MARK: - Private Startup Functions
  
  private func startPublicDatabaseOperations() {
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .userInitiated, reason: "Processing CloudKit data"))
    let fetchPublicStationsOperation = createFetchPublicStationsOperation()
    activityOperation.addDependency(fetchPublicStationsOperation)
    operationsQueue.addOperations([fetchPublicStationsOperation, activityOperation], waitUntilFinished: false)
  }
  
  private func startPrivateDatabaseOperations() {
    let zonesOperations = createSetupZoneOperations()
    let setupPrivateDatabaseSubscriptionsOperation = createSetupPrivateDatabaseSubscriptionsOperation()
    
    var operations = [zonesOperations, setupPrivateDatabaseSubscriptionsOperation]
    
    if UserDefaults.standard.bool(forKey: UserDefaultKeys.CloudKitPrivateDatabaseInitialSyncPerformed.rawValue) {
      let handlePrivateDatabaseChangesOperation = handlePrivateDatabaseChanges()
      setupPrivateDatabaseSubscriptionsOperation.addDependency(zonesOperations)
      handlePrivateDatabaseChangesOperation.addDependency(setupPrivateDatabaseSubscriptionsOperation)
    } else {
      let fetchInitialAllPrivateStationsOperation = createFetchInitialAllPrivateStationsOperation()
      operations.append(fetchInitialAllPrivateStationsOperation)
      fetchInitialAllPrivateStationsOperation.addDependency(zonesOperations)
      setupPrivateDatabaseSubscriptionsOperation.addDependency(fetchInitialAllPrivateStationsOperation)
    }
    
    operationsQueue.addOperations(operations, waitUntilFinished: false)
  }
  
  private func createSetupZoneOperations() -> Operation {
    let operation = setupZonesOperations()
    operation.qualityOfService = .utility
    
    return operation
  }
  
  private func createFetchPublicStationsOperation() -> Operation {
    let operation = BlockOperation() {
      self.fetchStations(database: CKContainer.default().publicCloudDatabase, since: self.lastPublicDatabaseSyncTimestamp) {
        self.lastPublicDatabaseSyncTimestamp = Date()
        self.setupPublicDatabaseSubscriptions()
      }
    }
    operation.qualityOfService = .utility
    
    return operation
  }
  
  private func createFetchInitialAllPrivateStationsOperation() -> Operation {
    let operation = BlockOperation() {
      self.fetchStations(database: CKContainer.default().privateCloudDatabase, since: Date.distantPast) {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.CloudKitPrivateDatabaseInitialSyncPerformed.rawValue)
      }
    }
    operation.qualityOfService = .utility
    
    return operation
  }
  
  private func createSetupPrivateDatabaseSubscriptionsOperation() -> Operation {
    let operation = BlockOperation() {
      self.setupPrivateDatabaseSubscriptions()
    }
    operation.qualityOfService = .utility
    
    return operation
  }
}
