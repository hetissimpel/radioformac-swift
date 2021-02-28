//
//  ScrollingTextView.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import Cocoa

final class ScrollingTextView: NSView {
  
  // MARK: -  Properties
  
   var text: NSString?
   var font: NSFont?
   var textColor: NSColor = .headerTextColor
   var spacing: CGFloat = 20

   var speed: Double = 4 {
    didSet {
      updateTraits()
    }
  }
  
  private var timer: Timer?
  private var point = NSPoint(x: 0, y: 0)
  private var timeInterval: TimeInterval?
  
  private(set) var stringSize = NSSize(width: 0, height: 0) {
    didSet {
      point.x = 0
    }
  }
  
  private var timerSpeed: Double? {
    return speed / 100
  }
  
  private lazy var textFontAttributes: [NSAttributedString.Key: Any] = {
    return [NSAttributedString.Key.font: font ?? NSFont.systemFont(ofSize: 14)]
  }()
  
  // MARK: - Init
  
   func setup(string: String) {
    text = string as NSString
    stringSize = text?.size(withAttributes: textFontAttributes) ?? NSSize(width: 0, height: 0)
    setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
    updateTraits()
  }
}

// MARK: - Private extension

private extension ScrollingTextView {
  func setSpeed(newInterval: TimeInterval) {
    clearTimer()
    timeInterval = newInterval
    
    guard let timeInterval = timeInterval else {
      return
      
    }
    
    if timer == nil, timeInterval > 0.0, text != nil {
      timer = Timer.scheduledTimer(timeInterval: newInterval, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
      
      guard let timer = timer else {
        return
      }
      
      RunLoop.main.add(timer, forMode: .common)
    } else {
      clearTimer()
      point.x = 0
    }
  }
  
  func updateTraits() {
    clearTimer()
    
    if stringSize.width > frame.width {
      guard let speed = timerSpeed else {
        return
      }
      
      setSpeed(newInterval: speed)
    } else {
      setSpeed(newInterval: 0.0)
    }
  }
  
  func clearTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func update(_ sender: Timer) {
    point.x = point.x - 1
    setNeedsDisplay(NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
  }
}

// MARK: - Overrides

extension ScrollingTextView {
  override func draw(_ dirtyRect: NSRect) {
    if point.x + stringSize.width < 0 {
      point.x += stringSize.width + spacing
    }
    
    textFontAttributes[NSAttributedString.Key.foregroundColor] = textColor
    text?.draw(at: point, withAttributes: textFontAttributes)
    
    if point.x < 0 {
      var otherPoint = point
      otherPoint.x += stringSize.width + spacing
      text?.draw(at: otherPoint, withAttributes: textFontAttributes)
    }
  }
  
  override  func layout() {
    super.layout()
    point.y = (frame.height - stringSize.height) / 2
  }
}
