//
//  DeletedRecordsToCoreDataOperation.swift
//  Radio
//
//  Created by Damien Glancy on 17/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import os.log

final class DeletedRecordsToCoreDataOperation: Operation {
  
  // MARK: - Properties
  
  var deletedRecordIDs: [CKRecord.ID] = []
  
  // MARK: - Lifecycle
  
  override func main() {
    os_log("DeletedRecordsToCoreDataOperation started.", log: CoreDataLog)
    
    super.main()
    
    let context = CoreData.shared.persistentContainer.newBackgroundContext()
    context.performChangesAndWait(updateCloudKit: false) {
      self.deletedRecordIDs.forEach { recordID in
        let entity = Station.fetchFirst(in: context, configure: { (fetchRequest) in
          fetchRequest.predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        })
        
        if let entity = entity {
          context.delete(entity)
        }
      }      
    }
    
    os_log("DeletedRecordsToCoreDataOperation finished.", log: CoreDataLog)
  }
}
