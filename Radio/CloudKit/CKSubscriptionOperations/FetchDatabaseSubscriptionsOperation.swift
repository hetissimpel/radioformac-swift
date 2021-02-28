//
//  FetchDatabaseSubscriptionsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 12/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class FetchDatabaseSubscriptionsOperation: CKFetchSubscriptionsOperation {
  
  // MARK: - Properties

  var fetchedDatabaseSubscriptions: [String: CKSubscription]?
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("FetchDatabaseSubscriptionsOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private
  
  private func setOperationBlocks() {
    fetchSubscriptionCompletionBlock = { [unowned self] (subscriptions: [String : CKSubscription]?, error: Error?) in
      if let error = error {
        os_log("FetchDatabaseSubscriptionsOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let subscriptions = subscriptions {
        self.fetchedDatabaseSubscriptions = subscriptions
        for subscription in subscriptions.keys {
          os_log("Subscription found: %@.", log: CloudKitLog, subscription)
        }
      }
      os_log("FetchDatabaseSubscriptionsOperation finished.", log: CloudKitLog)
    }
  }
  
}
