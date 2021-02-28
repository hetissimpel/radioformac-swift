//
//  ModifySubscriptionsOperation.swift
//  Radio
//
//  Created by Damien Glancy on 25/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import os.log

final class ModifySubscriptionsOperation: CKModifySubscriptionsOperation {
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("ModifySubscriptionsOperation started.", log: CloudKitLog)
    setOperationBlocks()
    super.main()
  }
  
  // MARK: - Private
  
  private func setOperationBlocks() {
    modifySubscriptionsCompletionBlock = { (modifiedSubscriptions: [CKSubscription]?, deletedSubscriptions: [String]?, error: Error?) -> Void in
      
      if let error = error {
        os_log("ModifySubscriptionsOperation error: %@.", log: CloudKitLog, error.localizedDescription)
      }
      
      if let modifiedSubscriptions = modifiedSubscriptions {
        for subscription in modifiedSubscriptions {
          os_log("Modified Subscription: %@.", log: CloudKitLog, subscription.subscriptionID)
        }
      }
      
      if let deletedSubscriptions = deletedSubscriptions {
        for subscriptionID in deletedSubscriptions {
          os_log("Deleted Subscription: %@.", log: CloudKitLog, subscriptionID)
        }
      }
    }
  }
}
