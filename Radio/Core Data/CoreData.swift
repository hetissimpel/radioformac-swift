//
//  CoreData.swift
//  Radio
//
//  Created by Damien Glancy on 09/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Cocoa
import CoreData
import os.log

final class CoreData {
  
  // MARK: - Singleton
  
  static let shared = CoreData()
  
  // MARK: - Properties
  
  private var persistentContainerStorage: NSPersistentContainer?
  
  // MARK: - Lifecycle
  
  private init() {}
  
  // MARK: - Core Data stack
  
  var persistentContainer: NSPersistentContainer {
    get {
      if persistentContainerStorage == nil {
        persistentContainerStorage = createPersistentContainerAndStore()
        persistentContainerStorage?.viewContext.automaticallyMergesChangesFromParent = true
      }
      return persistentContainerStorage!
    }
  }
  
  // MARK: - Actions
    
  func destroyPersistentContainerAndStore() {
    guard let storeUrl = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
      return
    }
        
    try! self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeUrl, ofType: NSSQLiteStoreType, options: nil)
    self.persistentContainerStorage = nil
  }
  
   func deleteAll(entityName: String, context: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try! context.execute(batchDeleteRequest)
    _ = context.saveOrRollback(updateCloudKit: false)
  }
  
  // MARK: - Private
  
  private func createPersistentContainerAndStore() -> NSPersistentContainer {
    let container = NSPersistentContainer(name: "Radio2")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    })
    return container
  }
  
}
