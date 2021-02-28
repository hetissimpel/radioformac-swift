//
//  RadioScriptListStationsCommand.swift
//  Radio
//
//  Created by Damien Glancy on 17/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import os.log

final class RadioScriptListStationsCommand: NSScriptCommand {
  
  // MARK: - Command Implementation
  
  override func performDefaultImplementation() -> Any? {
    os_log("Starting to execute List Stations command", log: ScriptingLog)

    os_log("Finished executing List Stations command", log: ScriptingLog)
    
    return nil
  }
}
