//
//  RadioDisplayViewController.swift
//  Radio
//
//  Created by Damien Glancy on 10/03/2019.
//  Copyright © 2019 Het is Simple BV. All rights reserved.
//

import Cocoa
import os.log

final class RadioDisplayViewController: NSViewController, RadioPlayerDelegate {
  
  // MARK: - Properties
    
  @IBOutlet weak var stationNameTextField: NSTextField!
  @IBOutlet weak var trackDetailsScrollingTextView: ScrollingTextView!
  
  @IBOutlet weak var playBtn: NSButton!
  @IBOutlet weak var favBtn: NSButton!
  @IBOutlet weak var recordBtn: NSButton!
  @IBOutlet weak var muteBtn: NSButton!
  @IBOutlet weak var volumeSlider: NSSlider!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    syncDisplay(withPlayer: RadioPlayer.shared)
  }
  
  override func viewDidDisappear() {
    super.viewDidDisappear()
    trackDetailsScrollingTextView.setup(string: kBlankString)
  }
  
  // MARK: - UI
  
  private func setupUI() {
    RadioPlayer.shared.delegate = self
    
    playBtn.alternateImage?.isTemplate = true
    muteBtn.image?.isTemplate = true
    muteBtn.alternateImage?.isTemplate = true
    muteBtn.state = UserDefaults.standard.bool(forKey: UserDefaultKeys.Mute.rawValue) ? .on : .off
    volumeSlider.floatValue = UserDefaults.standard.float(forKey: UserDefaultKeys.CurrentVolume.rawValue)
  }
  
  private func syncDisplay(withPlayer player: RadioPlayer) {
    os_log("Syncing display with player.", log: UILog)
    
    playBtn.isEnabled = RadioPlayer.shared.station != nil
    favBtn.isEnabled = RadioPlayer.shared.station != nil
    recordBtn.isEnabled = RadioPlayer.shared.station != nil
    
    stationNameTextField.stringValue = player.station?.name ?? NSLocalizedString("No Station", comment: "")
    trackDetailsScrollingTextView.setup(string: player.currentTrackMetadata?.rawValue ?? kBlankString)
    
    playBtn.state = player.isPlaying ? .on : .off
  }
  
  // MARK: - Actions
  
  @IBAction func playBtnPressed(_ sender: Any) {
    os_log("Play button pressed.", log: UILog)
    RadioPlayer.shared.toglePlay()
  }
  
  @IBAction func favBtnPressed(_ sender: Any) {
    os_log("Fav button pressed.", log: UILog)
  }
  
  @IBAction func recordBtnPressed(_ sender: Any) {
    os_log("Record button pressed.", log: UILog)
  }
  
  @IBAction func muteBtnPressed(_ sender: Any) {
    os_log("Mute button pressed.", log: UILog)
    if muteBtn.state == .on {
      os_log("Mute is now on.", log: AudioLog)
      setAudioMuted()
    } else {
      os_log("Mute is now off.", log: AudioLog)
      setAudioNotMuted()
    }
  }
  
  @IBAction func volumeSliderMoved(_ sender: Any) {
    guard let volumeSlider = sender as? NSSlider, let event = NSApplication.shared.currentEvent else {
      return
    }
    
    setAudioVolume(volumeSlider.floatValue, save: event.type == .leftMouseUp || event.type == .rightMouseUp)
  }
  
  // MARK: - Radio Player Delegate
  
  func radioPlayer(_ player: RadioPlayer, playerStateDidChange state: RadioPlayerState) {
    syncDisplay(withPlayer: player)
  }
  
  func radioPlayer(_ player: RadioPlayer, playbackStateDidChange state: RadioPlaybackState) {
    syncDisplay(withPlayer: player)
  }
  
  func radioPlayer(_ player: RadioPlayer, metadataDidChange trackMetadata: TrackMetadata?) {
    syncDisplay(withPlayer: player)
    
    if let trackMetadata = trackMetadata, let artistName = trackMetadata.artistName , let trackName = trackMetadata.trackName {
      sendLocalNotification(title: artistName, subtitle: trackName)
    }
  }
  
}
