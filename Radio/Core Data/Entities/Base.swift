//
//  Base.swift
//  Radio
//
//  Created by Damien Glancy on 19/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

// MARK: - Managed Protocol

protocol Managed: class, NSFetchRequestResult {
  static var entity: NSEntityDescription { get }
  static var entityName: String { get }
}

extension Managed where Self: NSManagedObject {
  
  // MARK: - Static Computed Properties
  
  static var entity: NSEntityDescription { return entity() }
  static var entityName: String { return entity.name! }
  
  // MARK: - Static Functions
  
  static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
    guard let object = findOrFetch(in: context, matching: predicate) else {
      let newObject: Self = Self(context: context)
      configure(newObject)
      return newObject
    }
    
    return object
  }
  
  static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
    guard let object = materializedObject(in: context, matching: predicate) else {
      return fetchFirst(in: context) { request in
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
      }
    }
    
    return object
  }
  
  static func fetch(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
    let request = NSFetchRequest<Self>(entityName: Self.entityName)
    configure(request)
    return try! context.fetch(request)
  }
  
  static func fetchFirst(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Self? {
    let request = NSFetchRequest<Self>(entityName: Self.entityName)
    request.fetchLimit = 1
    configure(request)
    return try! context.fetch(request).first ?? nil
  }
  
  static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Int {
    let request = NSFetchRequest<Self>(entityName: entityName)
    configure(request)
    return try! context.count(for: request)
  }
  
  static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
    for object in context.registeredObjects where !object.isFault {
      guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
      return result
    }
    
    return nil
  }
}

// MARK: - BaseMO

class BaseMO: NSManagedObject, Managed {
  
  // MARK: - Properties
  
  @NSManaged var identifier: UUID?
  @NSManaged var createdAt: Date?
  @NSManaged var updatedAt: Date?
  
  // MARK: - Functions
  
  func updateProperties() {
    updateTimestamps()
    if identifier == nil { createUUID() }
  }
  
  // MARK: - Private Functions
  
  private func createUUID() {
    identifier = UUID()
  }
  
  private func updateTimestamps() {
    let date = Date()
    if createdAt == nil {
      createdAt = date
    }
    updatedAt = date
  }
}

// MARK: - BaseCKRecordMO

class BaseCKRecordMO: BaseMO {
  
  // MARK: - Constants
  
  private static let KeysNotToPushToCloud = ["recordID", "publicZone", "recordName", "userDefined", "createdAt", "updatedAt"]
  
  // MARK: - Properties
  
  @NSManaged var recordName: String?
  @NSManaged var recordID: Data?
  
  // MARK: - Functions
  
  func updateFromCloud(record: CKRecord) {
    recordName = record.recordID.recordName
    recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID)
    
    if let recordID = recordID {
      identifier = UUID(uuidString: String(data: recordID, encoding: .utf8) ?? "")
    }
    
    for key in record.allKeys() {
      let object: Any = {
        switch key {
        case "url":
          return URL(string: record.object(forKey: key) as! String) as Any
        case "isSoftDeleted":
          return ((record.object(forKey: key) as! Int) == 1 ? true : false ) as Any
        default:
          return record.object(forKey: key) as Any
        }
      }()
      
      setValue(object, forKey: key)
    }
  }
  
  func cloudKitRecordID() -> CKRecord.ID? {
    guard let recordID = recordID else {
      return nil
    }
    
    return NSKeyedUnarchiver.unarchiveObject(with: recordID) as? CKRecord.ID
  }
  
  func cloudKitRecord() -> CKRecord {
    let record: CKRecord
    
    if cloudKitRecordID() == nil {
      record = CKRecord(recordType: entity.name!, recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: CKRecordZone.ID(zoneName: CloudKitZone.RadioZone.rawValue, ownerName: CKCurrentUserDefaultName)))
    } else {
      record = CKRecord(recordType: entity.name!, recordID: cloudKitRecordID()!)
    }
    
    recordName = record.recordID.recordName
    recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID)

    for key in entity.attributesByName.keys where !BaseCKRecordMO.KeysNotToPushToCloud.contains(key) {
      let object: Any = {
        switch key {
        case "url":
          return (value(forKey: key) as? URL)?.absoluteString as Any
        default:
          return value(forKey: key) as Any
        }
      }()
      
      record.setObject(object as? CKRecordValue, forKey: key)
    }
    
    return record
  }
}

enum BaseMOType: String, CaseIterable {
  case Station = "Station"
}
