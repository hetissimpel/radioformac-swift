//
//  ProcessDatabaseSubscriptionsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 12/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class ProcessDatabaseSubscriptionsOperation: Operation {
  
  // MARK: - Properties
  
  var preProcessDatabaseSubscriptions: [String: CKSubscription] = [:]
  var postProcessDatabaseSubscriptionsToCreate: [CKSubscription] = []
  var postProcessDatabaseSubscriptionIDsToDelete: [String]?
  var querySubscriptionOptions: CKQuerySubscription.Options?
  var zoneID: CKRecordZone.ID?
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("ProcessDatabaseSubscriptionsOperation started.", log: CloudKitLog )
    
    if preProcessDatabaseSubscriptions.isEmpty {
      setSubscriptionNamesToCreate()
    } else {
      os_log("ProcessDatabaseSubscriptionsOperation found no subscription to process; ignoring.", log: CloudKitLog )
    }
    
    super.main()
    os_log("ProcessDatabaseSubscriptionsOperation finished.", log: CloudKitLog)
  }
  
  // MARK: - Private
  
  private func setSubscriptionNamesToCreate() {
    guard let querySubscriptionOptions = querySubscriptionOptions else {
      return
    }
    
    let subscription = CKQuerySubscription(recordType: "Station", predicate: NSPredicate(value: true), options: querySubscriptionOptions)
    if let zoneID = zoneID {
      subscription.zoneID = zoneID
    }
    
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true
    notificationInfo.alertBody = kBlankString
    subscription.notificationInfo = notificationInfo
    
    postProcessDatabaseSubscriptionsToCreate.append(subscription)
  }
}
