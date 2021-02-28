//
//  RadioPlayer.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Foundation
import AVFoundation

@objc
final class RadioPlayer: NSObject {
  
  // MARK: - Public Properties
  
  static let shared = RadioPlayer()
  
  weak var delegate: RadioPlayerDelegate?
  
  var station: Station? {
    didSet {
      radioStationDidChange(with: station)
    }
  }
  
  var isPlaying: Bool {
    switch playbackState {
    case .playing:
      return true
    case .stopped, .paused:
      return false
    }
  }
  
  var muted: Bool = false
  
  var volume: Float {
    get {
      return player.volume
    }
    
    set {
      if !muted {
        player.volume = newValue
      }
    }
  }
  
  var currentTrackMetadata: TrackMetadata?
  
  // MARK: - Private Properties

  private let reachability = Reachability()!
  private var player: AVPlayer = AVPlayer()
  
  private var playerItem: AVPlayerItem? {
    didSet {
      playerItemDidChange()
    }
  }
  
  private(set) var state = RadioPlayerState.urlNotSet {
    didSet {
      guard oldValue != state else {
        return
      }
      
      delegate?.radioPlayer(self, playerStateDidChange: state)
    }
  }
  
  private(set) var playbackState = RadioPlaybackState.stopped {
    didSet {
      guard oldValue != playbackState else {
        return
      }
      
      delegate?.radioPlayer(self, playbackStateDidChange: playbackState)
    }
  }
  
  private var isConnected = false
  
  // MARK: - Lifecycle

  override private init() {
    super.init()
    setupNotifications()
    try? reachability.startNotifier()
    isConnected = reachability.connection != .none
  }
  
  deinit {
    resetPlayer()
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notifications
  
  private func setupNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
  }
  
  // MARK: - Actions
  
  func play(station: Station) {
    self.station = station
    play()
  }
  
  func play() {
    if player.currentItem == nil, playerItem != nil {
      player.replaceCurrentItem(with: playerItem)
    }
    
    player.play()
    playbackState = .playing
  }
  
  func stop() {
    player.replaceCurrentItem(with: nil)
    timedMetadataDidChange(rawValue: nil)
    playbackState = .stopped
  }
  
  func toglePlay() {
    isPlaying ? stop() : play()
  }
  
  // MARK: - Player & Asset Management
  
  private func radioStationDidChange(with station: Station?) {
    guard let station = station, let url = station.url else {
      return
    }
    
    preparePlayer(with: AVAsset(url: url)) { (success, asset) in
      guard success, let asset = asset else {
        self.resetPlayer()
        self.state = .error
        return
      }
      
      self.playerItem = AVPlayerItem(asset: asset)
    }
  }
  
  private func playerItemDidChange() {
    if let item = playerItem {
      item.addObserver(self, forKeyPath: "timedMetadata", options: NSKeyValueObservingOptions.new, context: nil)
      player.replaceCurrentItem(with: item)
    }
  }
  
  private func preparePlayer(with asset: AVAsset?, completionHandler: @escaping (_ isPlayable: Bool, _ asset: AVAsset?)->()) {
    guard let asset = asset else {
      completionHandler(false, nil)
      return
    }
       
    asset.loadValuesAsynchronously(forKeys: ["playable"]) {
      DispatchQueue.main.async {
        var error: NSError?
        
        let keyStatus = asset.statusOfValue(forKey: "playable", error: &error)
        if keyStatus == AVKeyValueStatus.failed || !asset.isPlayable {
          completionHandler(false, nil)
          return
        }
        
        completionHandler(true, asset)
      }
    }
  }
  
  private func resetPlayer() {
    stop()
    playerItem = nil
    currentTrackMetadata = nil
    player = AVPlayer()
  }
  
  private func reloadItem() {
    player.replaceCurrentItem(with: nil)
    player.replaceCurrentItem(with: playerItem)
  }
  
  private func timedMetadataDidChange(rawValue: String?) {
    currentTrackMetadata = TrackMetadata(rawValue: rawValue)
    delegate?.radioPlayer?(self, metadataDidChange: currentTrackMetadata)
  }
  
  // MARK: - Reachability & Network Condition Handling
  
  @objc func reachabilityChanged(notification: Notification) {
    guard let reachability = notification.object as? Reachability else {
      return
    }
    
    if reachability.connection != .none, !isConnected {
      checkNetworkInterruption()
    }
    
    isConnected = reachability.connection != .none
  }
  
  private func checkNetworkInterruption() {
    guard let item = playerItem, !item.isPlaybackLikelyToKeepUp, reachability.connection != .none else {
        return
    }
    
    player.pause()
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      if !item.isPlaybackLikelyToKeepUp {
        self.reloadItem()
      }
      
      self.isPlaying ? self.player.play() : self.player.pause()
    }
  }
  
  // MARK: - KVO

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let item = object as? AVPlayerItem, let keyPath = keyPath, item == playerItem {
      switch keyPath {
        
      case "status":
        if player.status == AVPlayer.Status.readyToPlay {
          self.state = .readyToPlay
        } else if player.status == AVPlayer.Status.failed {
          self.state = .error
        }
        
      case "playbackBufferEmpty":
        if item.isPlaybackBufferEmpty {
          self.state = .loading
          self.checkNetworkInterruption()
        }
        
      case "playbackLikelyToKeepUp":
        self.state = item.isPlaybackLikelyToKeepUp ? .loadingFinished : .loading
        
      case "timedMetadata":
        if let rawValue = item.timedMetadata?.first?.value as? String {
          timedMetadataDidChange(rawValue: rawValue)
        }
        
      default:
        break
      }
    }
  }
}

// MARK: - Enums

@objc enum RadioPlaybackState: Int {
  case playing, paused, stopped
  
  var description: String {
    switch self {
    case .playing: return "Radio Player is playing"
    case .paused: return "Radio Player is paused"
    case .stopped: return "Radio Player is stopped"
    }
  }
}

@objc enum RadioPlayerState: Int {
  case urlNotSet, readyToPlay, loading, loadingFinished, error
  
  var description: String {
    switch self {
    case .urlNotSet: return "URL is not set"
    case .readyToPlay: return "Ready to play"
    case .loading: return "Loading"
    case .loadingFinished: return "Loading finished"
    case .error: return "Error"
    }
  }
}

// MARK: - TrackMetadata

@objc class TrackMetadata: NSObject {
  var artistName: String?
  var trackName: String?
  var rawValue: String?
  
  init(rawValue: String?) {
    self.rawValue = rawValue
    if let parts = rawValue?.components(separatedBy: " - ") {
      self.artistName = parts.first
      self.trackName = parts.last
    }
  }
}

// MARK: - Delegate Protocol

@objc protocol RadioPlayerDelegate {
  func radioPlayer(_ player: RadioPlayer, playerStateDidChange state: RadioPlayerState)
  func radioPlayer(_ player: RadioPlayer, playbackStateDidChange state: RadioPlaybackState)
  @objc optional func radioPlayer(_ player: RadioPlayer, itemDidChange url: URL?)
  @objc optional func radioPlayer(_ player: RadioPlayer, metadataDidChange trackMetadata: TrackMetadata?)
}

