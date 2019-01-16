# TwitchPlayer

![](https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/StreamPlay.png)

[![CI Status](https://img.shields.io/travis/chrisfromtemporaryid@gmail.com/TwitchPlayer.svg?style=flat)](https://travis-ci.org/chrisfromtemporaryid@gmail.com/TwitchPlayer)
[![Version](https://img.shields.io/cocoapods/v/TwitchPlayer.svg?style=flat)](https://cocoapods.org/pods/TwitchPlayer)
[![License](https://img.shields.io/cocoapods/l/TwitchPlayer.svg?style=flat)](https://cocoapods.org/pods/TwitchPlayer)
[![Platform](https://img.shields.io/cocoapods/p/TwitchPlayer.svg?style=flat)](https://cocoapods.org/pods/TwitchPlayer)

**THIS IS AN UNOFFICIAL, FAN-MADE WRAPPER. IT IS IN NO WAY ENDORSED BY TWITCH.TV**

## What is It?

Twitch Player is a library that helps you embed Twitch Streams, Clips, Videos, and Collections into your application easily. You can embed directly from the Storyboard or programmatically.

### Example Usage

From the storyboard, drag a WKWebView onto a ViewController. Set it's subclass to `TwitchPlayer` (for Stream, Video, or Collection playing) or `TwitchClipPlayer` (for Clip playing)

![](https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/StoryboardInject.png)

You can then modify the variables directly from the Storyboard.

![](https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/StoryboardProperties.png)

## Example Project

![](https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/ClipPlay.png)

An example project is provided with this project that shows the storyboard-creation of a Clip Player, Stream Player, and Video Player

To run the example project, clone the repo, and run `pod install` from the Example directory. After that, open the resulting `.xcworkspace` file and go nuts!

## Documentation

[Documentation available here](https://htmlpreview.github.io/?https://github.com/Chris-Perkins/TwitchPlayer/blob/master/docs/index.html)

- If the documentation is not loading, clone this repository and open `docs/index.html`.

## Installation

1. Install [CocoaPods](https://cocoapods.org)
1. Add this repo to your `Podfile`

	```ruby
	target 'Example' do
		# IMPORTANT: Make sure use_frameworks! is included at the top of the file
		use_frameworks!

		pod 'TwitchPlayer'
	end
	```
1. Run `pod install` in the podfile directory from your terminal
1. Open up the `.xcworkspace` that CocoaPods created
1. Done!

## License

TwitchPlayer is available under the MIT license. See the LICENSE file for more info.
