//
//  GlobalFunctions.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import UserNotifications
import os.log

// MARK: - Audio UI Helpers

func setAudioVolume(_ volume: Float, save: Bool = false) {
  RadioPlayer.shared.volume = volume
  
  if save {
    UserDefaults.standard.set(volume, forKey: UserDefaultKeys.CurrentVolume.rawValue)
    os_log("Setting user preferred volume: %.2f.", log: UILog, volume)
  }
}

func setAudioMuted() {
  os_log("Setting user preference for muted.", log: UILog)
  RadioPlayer.shared.volume = 0
  RadioPlayer.shared.muted = true
  UserDefaults.standard.set(true, forKey: UserDefaultKeys.Mute.rawValue)
}

func setAudioNotMuted() {
  os_log("Setting user preference for unmuted.", log: UILog)
  UserDefaults.standard.set(false, forKey: UserDefaultKeys.Mute.rawValue)
  RadioPlayer.shared.muted = false
  setAudioVolume(UserDefaults.standard.float(forKey: UserDefaultKeys.CurrentVolume.rawValue))
}

// MARK: - Local Notifications

func sendLocalNotification(title: String, subtitle: String, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
  if #available(macOS 10.14, *) {
    os_log("Sending local notification via modern SDK. Title: %@, Subtitle: %@.", log: UILog, title, subtitle)
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil), withCompletionHandler: completionHandler)
  } else {
    os_log("Sending local notification via legacy SDK. Title: %@, Subtitle: %@.", log: UILog, title, subtitle)

    let notification = NSUserNotification()
    notification.title = title
    notification.subtitle = subtitle
    
    NSUserNotificationCenter.default.deliver(notification)
    if let completionHandler = completionHandler {
      completionHandler(nil)
    }
  }
}
