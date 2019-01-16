//
//  TwitchStreamPlayerViewController.swift
//  TwitchPlayer
//
//  Created by chrisfromtemporaryid@gmail.com on 01/16/2019.
//  Copyright (c) 2019 chrisfromtemporaryid@gmail.com. All rights reserved.
//

import UIKit

public class TwitchStreamPlayerViewController: TwitchPlayerViewController {

    /// `streamsArray` holds the streams that will be cycled through.
    private static let streamsArray = ["stadium", "monstercat"]

    /// `nextStreamIndex` holds the index of the stream that should be cycled to next.
    private var nextStreamIndex = 0

    /// Activates whenever the button labeled "Next" is pressed. This will play the next stream in the above array.
    ///
    /// - Parameter sender: The button labeled "Next"
    @IBAction func nextButtonPress(_ sender: Any) {
        let streamToPlay = TwitchStreamPlayerViewController.streamsArray[nextStreamIndex]
        nextStreamIndex = (nextStreamIndex + 1) % TwitchStreamPlayerViewController.streamsArray.count
        twitchPlayer.setChannel(to: streamToPlay)
    }
}
