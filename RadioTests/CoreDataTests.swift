//
//  CoreDataTests.swift
//  RadioTests
//
//  Created by Damien Glancy on 06/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import XCTest
@testable import Radio

class CoreDataTests: BaseXCTestCase {
  
  // MARK: - Properties
  
  let viewContext = CoreData.shared.persistentContainer.viewContext
  
  // MARK: - Lifecycle
  
  override func tearDown() {
    super.tearDown()
    CoreData.shared.deleteAll(entityName: "Station", context: viewContext)
  }
  
  // MARK: - Tests
  
  func testCoreDataShared() {
    XCTAssertTrue(CoreData.shared === CoreData.shared)
  }
  
  func testPersistentContainer() {
    XCTAssertNotNil(CoreData.shared.persistentContainer)
    XCTAssertNotNil(CoreData.shared.persistentContainer.persistentStoreCoordinator)
    XCTAssertNotNil(CoreData.shared.persistentContainer.persistentStoreCoordinator.persistentStores)
    XCTAssertEqual(1, CoreData.shared.persistentContainer.persistentStoreCoordinator.persistentStores.count)
  }
  
  func testSaveContextWhenNothingToSave() {
    XCTAssertFalse(viewContext.hasChanges)
    _ = viewContext.saveOrRollback()
  }
  
  func testSaveContext() {
    XCTAssertFalse(viewContext.hasChanges)
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    
    XCTAssertTrue(viewContext.hasChanges)
    XCTAssertNil(object.createdAt)
    XCTAssertNil(object.updatedAt)
    XCTAssertNil(object.identifier)
    
    _ = viewContext.saveOrRollback()
    
    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertNotNil(object.createdAt)
    XCTAssertNotNil(object.updatedAt)
    XCTAssertNotNil(object.identifier)
  }
  
  func testSaveContextUpdatedAt() {
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    XCTAssertNotNil(object.createdAt)
    XCTAssertNotNil(object.updatedAt)
    XCTAssertEqual(object.createdAt, object.updatedAt)
    
    object.url = URL(string: "http://example.com/updated.mp3")
    _ = viewContext.saveOrRollback()
    XCTAssertNotNil(object.createdAt)
    XCTAssertNotNil(object.updatedAt)
    XCTAssertNotEqual(object.createdAt, object.updatedAt)
  }
  
  func testCreateNewStation() {
    let entity = Station(context: viewContext)
    XCTAssertNotNil(entity)
  }
  
  func testEntityName() {
    XCTAssertEqual("Station", Station.entityName)
  }
  
  func testEntityDescription() {
    XCTAssertNotNil(Station.entity)
    XCTAssertTrue(Station.entity.isKind(of: NSEntityDescription.self))
  }
  
  func testFetch() {
    let fetchRequest = NSFetchRequest<Station>(entityName: "Station")
    fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    
    var results = Station.fetch(in: viewContext) { (fetchRequest) in
      fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    }
    
    XCTAssertEqual(0, results.count)
    XCTAssertEqual([], results)
    
    let entity = Station(context: viewContext)
    entity.recordName = "TestRecordName"
    entity.name = "TestName"
    entity.url = URL(string: "https://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    results = Station.fetch(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    }
    
    XCTAssertEqual(1, results.count)
    XCTAssertEqual([entity], results)
  }
  
  func testFetchFirst() {
    let fetchRequest = NSFetchRequest<Station>(entityName: "Station")
    fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    
    var result = Station.fetchFirst(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    }
    
    XCTAssertNil(result)
    
    let entity = Station(context: viewContext)
    entity.recordName = "TestRecordName"
    entity.name = "TestName"
    entity.url = URL(string: "https://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    result = Station.fetchFirst(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "recordName == %@", "TestRecordName")
    }
    
    XCTAssertNotNil(result)
    XCTAssertEqual(entity, result)
  }
  
  func testCountPublicStations() {
    XCTAssertEqual(0, Station.count(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "isUserDefined == NO and isSoftDeleted == NO")
      fetchRequest.includesSubentities = false
    })
    
    let userStation = Station(context: viewContext)
    userStation.name = "UserStation"
    userStation.url = URL(string: "https://example.com/user_example.mp3")
    userStation.isUserDefined = true
    _ = viewContext.saveOrRollback()
    
    XCTAssertEqual(0, Station.count(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "isUserDefined == NO and isSoftDeleted == NO")
      fetchRequest.includesSubentities = false
    })

    let publicStation = Station(context: viewContext)
    publicStation.name = "PublicStation"
    publicStation.url = URL(string: "https://example.com/public_example.mp3")
    _ = viewContext.saveOrRollback()

    XCTAssertEqual(1, Station.count(in: viewContext) { fetchRequest in
      fetchRequest.predicate = NSPredicate(format: "isUserDefined == NO and isSoftDeleted == NO")
      fetchRequest.includesSubentities = false
    })
  }
  
  func testPerformChanges() {
    let expectation = XCTestExpectation(description: "Core Data")
    
    XCTAssertFalse(viewContext.hasChanges)
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    
    XCTAssertTrue(viewContext.hasChanges)
    XCTAssertNil(object.createdAt)
    XCTAssertNil(object.updatedAt)
    XCTAssertNil(object.identifier)
    
    viewContext.performChangesAndWait(updateCloudKit: false) {
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: kDefaultTestTimeout)
    
    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertNotNil(object.createdAt)
    XCTAssertNotNil(object.updatedAt)
    XCTAssertNotNil(object.identifier)
  }

  func testInsertObject() {
    let station = Station(context: viewContext)
    XCTAssertNotNil(station)
    XCTAssertEqual(1, viewContext.insertedObjects.count)
  }
  
  func testmaterializedObject() {
    let predicate = NSPredicate(format: "name = %@", "Mister")
    
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    viewContext.reset()

    let faultedFoundObject = Station.fetchFirst(in: viewContext) { fetchRequest in
      fetchRequest.predicate = predicate
      fetchRequest.returnsObjectsAsFaults = true
    }
    XCTAssertNotNil(faultedFoundObject)
    XCTAssertTrue(faultedFoundObject!.isFault)
    
    var materializedObject = Station.materializedObject(in: viewContext, matching: predicate)
    XCTAssertNil(materializedObject)
    
    viewContext.reset()
    
    let unfaultedFoundObject = Station.fetchFirst(in: viewContext) { fetchRequest in
      fetchRequest.predicate = predicate
      fetchRequest.returnsObjectsAsFaults = false
    }
    XCTAssertNotNil(unfaultedFoundObject)
    XCTAssertFalse(unfaultedFoundObject!.isFault)

    materializedObject = Station.materializedObject(in: viewContext, matching: predicate)
    XCTAssertNotNil(materializedObject)
  }
  
  func testFindOrFetch() {
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    let foundObject = Station.findOrFetch(in: viewContext, matching: NSPredicate(format: "name = %@", "Mister"))
    XCTAssertNotNil(foundObject)
    XCTAssertEqual(object, foundObject)
  }
  
  func testFindOrFetchNotFound() {
    let object = Station(context: viewContext)
    object.name = "Mister"
    object.url = URL(string: "http://example.com/mp3")
    _ = viewContext.saveOrRollback()
    
    let foundObject = Station.findOrFetch(in: viewContext, matching: NSPredicate(format: "name = %@", "Won't be found"))
    XCTAssertNil(foundObject)
  }
  
  func testFindOrCreate() {
    let object = Station.findOrCreate(in: viewContext, matching: NSPredicate(format: "name = %@", "Mister")) { station in
      station.name = "Mister"
    }
    
    XCTAssertNotNil(object)
    XCTAssertEqual("Mister", object.name)
    
    let object2 = Station.findOrCreate(in: viewContext, matching: NSPredicate(format: "name = %@", "Mister")) { station in
      station.name = "Mister"
    }
    
    XCTAssertNotNil(object2)
    XCTAssertEqual(object, object2)
  }
}

class CoreDataDestructionTests: BaseXCTestCase {
  
  // MARK: - Tests
  
  func testDestroyPersistentStore() {
    let originalPersistentStore = CoreData.shared.persistentContainer.persistentStoreCoordinator.persistentStores.first!
    CoreData.shared.destroyPersistentContainerAndStore()
    let newPersistentStore = CoreData.shared.persistentContainer.persistentStoreCoordinator.persistentStores.first!
    XCTAssertFalse(originalPersistentStore === newPersistentStore)
  }
}
