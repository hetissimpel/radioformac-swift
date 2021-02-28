//
//  Station.swift
//  Radio
//
//  Created by Damien Glancy on 19/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit
import os.log

// MARK: - Managed Objectes

@objc(Station)
final class Station: BaseCKRecordMO {
  
  // MARK: - Properties
    
  @NSManaged var name: String?
  @NSManaged var url: URL?
  @NSManaged var city: String?
  @NSManaged var country: String?
  @NSManaged var desc: String?
  @NSManaged var isUserDefined: Bool
  
}
