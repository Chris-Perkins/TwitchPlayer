//
//  TwitchVideoPlayerViewController.swift
//  TwitchPlayer_Example
//
//  Created by Christopher Perkins on 1/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

public class TwitchVideoPlayerViewController: TwitchPlayerViewController {

    /// `videosArray` holds the videos that will be cycled through.
    private static let videosArray = ["362456756", "356414012"]

    /// `nextStreamIndex` holds the index of the video that should be cycled to next.
    private var nextVideoIndex = 0
    
    /// Activates whenever the button labeled "Next" is pressed. This will play the next video in the above array.
    ///
    /// - Parameter sender: The button labeled "Next"
    @IBAction func nextButtonPress(_ sender: Any) {
        let videoToPlay = TwitchVideoPlayerViewController.videosArray[nextVideoIndex]
        nextVideoIndex = (nextVideoIndex + 1) % TwitchVideoPlayerViewController.videosArray.count
        twitchPlayer.setVideo(to: videoToPlay, timestamp: 0)
    }
}
