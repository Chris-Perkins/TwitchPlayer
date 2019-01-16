//
//  TwitchClipPlayerViewController.swift
//  TwitchPlayer_Example
//
//  Created by Christopher Perkins on 1/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import TwitchPlayer

public class TwitchClipPlayerViewController: UIViewController {
    
    /// `clipsArray` holds the clips that will be cycled through.
    private static let clipsArray = ["SpikyColorfulInternArsonNoSexy", "ApatheticStupidDuckDendiFace"]
    
    /// `nextClipIndex` holds the index of the clip that should be cycled to next.
    private var nextClipIndex = 0
    
    /// `clipPlayer` is the player for the actual clip itself.
    @IBOutlet weak var clipPlayer: TwitchClipPlayer!
    
    /// Activates whenever the button labeled "Next" is pressed. This will play the next clip in the above array.
    ///
    /// - Parameter sender: The button labeled "Next"
    @IBAction func nextButtonPress(_ sender: Any) {
        let clipToPlay = TwitchClipPlayerViewController.clipsArray[nextClipIndex]
        nextClipIndex = (nextClipIndex + 1) % TwitchClipPlayerViewController.clipsArray.count
        clipPlayer.clipId = clipToPlay
    }
}
