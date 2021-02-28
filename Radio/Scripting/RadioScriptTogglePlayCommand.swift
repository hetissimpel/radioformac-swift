//
//  RadioScriptTogglePlayCommand.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import os.log

final class RadioScriptTogglePlayCommand: NSScriptCommand {
  
  // MARK: - Command Implementation
  
  override func performDefaultImplementation() -> Any? {
    os_log("Starting to execute TogglePlay command", log: ScriptingLog)
    RadioPlayer.shared.toglePlay()
    os_log("Finished executing TogglePlay command", log: ScriptingLog)

    return nil
  }
}
