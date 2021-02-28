//
//  CloudKit+Common.swift
//  Radio
//
//  Created by Damien Glancy on 26/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

// MARK: - Enums

enum CloudKitZone: String, CaseIterable {
  case RadioZone = "RadioZone"
  
  // MARK: - Properties

  static let allCloudKitZoneNames = CloudKitZone.allCases.map { $0.rawValue }
    
  var recordZoneID: CKRecordZone.ID {
    return CKRecordZone.ID(zoneName: rawValue, ownerName: CKCurrentUserDefaultName)
  }
  
  // MARK: - Constructor
  
  init?(recordType: String) {
    switch recordType {
    case BaseMOType.Station.rawValue : self = .RadioZone
    default : return nil
    }
  }
}

// MARK: - Extensions

extension CloudKit {

  // MARK: - Fetch
  
  func fetchStations(database: CKDatabase, since timestamp: Date, _ completionBlock: (() -> Void)? = nil) {
    let activityOperation = ActivityOperation(activity: ProcessInfo.processInfo.beginActivity(options: .userInitiated, reason: "Processing CloudKit data"))

    let fetchStationRecordsOperation = FetchStationRecordsOperation(database: database, since: timestamp) { (records: [CKRecord]) in
      let saveChangedRecordsToCoreDataOperation = SaveChangedRecordsToCoreDataOperation()
      saveChangedRecordsToCoreDataOperation.changedRecords = records
      saveChangedRecordsToCoreDataOperation.completionBlock = completionBlock
      self.operationsQueue.addOperation(saveChangedRecordsToCoreDataOperation)
    }
    
    activityOperation.addDependency(fetchStationRecordsOperation)
    
    operationsQueue.addOperations([fetchStationRecordsOperation, activityOperation], waitUntilFinished: false)
  }
}

extension CKRecordZone.ID {
  
  // MARK: - Properties
  
  var lastUsedChangeToken: CKServerChangeToken? {
    get {
      guard let data = UserDefaults.standard.value(forKey: zoneName) as? Data else {
        return nil
      }
      
      guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken  else{
        return nil
      }
      
      return token
    }
    
    set {
      if let token = newValue {
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        UserDefaults.standard.set(data, forKey: zoneName)
      } else {
        UserDefaults.standard.removeObject(forKey: zoneName)
      }
    }
  }
}

extension CKDatabase {
  
  // MARK: - Properties
  
  var lastUsedChangeToken: CKServerChangeToken? {
    get {
      guard let data = UserDefaults.standard.value(forKey: databaseScope.toString()) as? Data else {
        return nil
      }
      
      guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken  else{
        return nil
      }
      
      return token
    }
    
    set {
      if let token = newValue {
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        UserDefaults.standard.set(data, forKey: databaseScope.toString())
      } else {
        UserDefaults.standard.removeObject(forKey: databaseScope.toString())
      }
    }
  }
}

extension CKDatabase.Scope {
  
  // MARK: - Functions
  
  func toString() -> String {
    return String(rawValue)
  }
}

