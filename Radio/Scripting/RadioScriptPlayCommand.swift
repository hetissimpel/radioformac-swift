//
//  RadioScriptPlayCommand.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import os.log

final class RadioScriptPlayCommand: NSScriptCommand {
  
  // MARK: - Command Implementation
  
  override func performDefaultImplementation() -> Any? {
    os_log("Starting to execute Play command", log: ScriptingLog)
    RadioPlayer.shared.play()
    os_log("Finished executing Play command", log: ScriptingLog)
    
    return nil
  }
}
