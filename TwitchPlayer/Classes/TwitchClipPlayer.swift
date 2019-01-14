//
//  TwitchClipPlayer.swift
//  TwitchPlayer
//
//  Created by Christopher Perkins on 1/14/19.
//

import WebKit

/// `TwitchClipPlayer` is a class that allows for the encapsulation of the loading of a non-interactive Twitch Clip
/// Embedded Player as specified by the Twitch Documentation.
///
/// In this class, you can modify the following variables:
/// TODO: Variables here
@IBDesignable public class TwitchClipPlayer: WKWebView {

    /// `htmlParameterDelimiter` is used to delimiter different parameters in HTML.
    private static let htmlParameterDelimiter = "\n"

    /// `htmlKeyValueDelimiter` is used to delimit a HTML key and value.
    private static let htmlKeyValueDelimiter = "="
    
    /// `ScrollingValues` defines the different types of values that the `scrolling` attribute that a Twitch Clip Player
    /// can have.
    ///
    /// - yes: Scrolling is enabled
    /// - no: Scrolling is disabled
    private enum ScrollingValues: String {
        case yes
        case no
    }

    /// `initializationReplacementKey` specifies the String that should be replaced in `playerHtmlContent` to add
    /// additional initialization properties.
    private static let initializationReplacementKey = "{0}"

    /// `clipReplacementKey` specifies the String that should be replaced in `playerHtmlContent` to set the clip value.
    private static let clipReplacementKey = "<slug>"

    /// `playerHtmlContent` holds the HTML Content as a String regarding a Twitch Clip Embedded player.
    private static let playerHtmlContent =
"""
<iframe
    src="https://clips.twitch.tv/embed?clip=<slug>"
    height="100%"
    width="100%"
    frameborder="0"
    {0}
</iframe>
"""

    /// `scrollingEnabled` is a settable variable that determines if the Twitch Clip Player allows scrolling. Default:
    /// `false`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var scrollingEnabled: Bool = false {
        didSet {
            updateWebPlayer()
        }
    }

    /// `muteOnLoad` is a settable variable that determines if a Twitch Clip Player will be muted upon initialization.
    /// Default: `false`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var muteOnLoad: Bool = false {
        didSet {
            updateWebPlayer()
        }
    }

    /// `autoPlayEnabled` is a settable variable that determines if a Twitch Clip Player plays automatically upon
    /// initialization. Default: `false`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var autoPlayEnabled: Bool = false {
        didSet {
            updateWebPlayer()
        }
    }

    /// `allowsFullScreen` is a settable variable that determines if the Twitch Clip Player allows full screen. Default:
    /// `true`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var allowsFullScreen: Bool = true {
        didSet {
            updateWebPlayer()
        }
    }

    /// `clipId` is a settable variable that determines which clip will be loaded in this clip player. Default: `""`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var clipId: String = "" {
        didSet {
            updateWebPlayer()
        }
    }

    /// `updateWebPlayer` will update the loaded Twitch Player with the current parameters of the Twitch Player.
    private func updateWebPlayer() {
        let playerHtml = ""
        loadHTMLString(playerHtml, baseURL: nil)
    }

    /// `getPlayerHtmlString` is used to retrieve the HTML of an embedded web player for Twitch.
    ///
    /// - Parameters:
    ///   - channelToLoad: The channel to view
    ///   - videoToLoad: The video to view
    ///   - collectionToLoad: The collection to load
    ///   - playerLayout: The layout of the web player
    ///   - chatMode: The mode of the web player
    ///   - fontSize: The font size of the web player
    ///   - playerTheme: The theme of the web player
    ///   - allowsFullScreen: Whether or not full screen is allowed in the web player
    private func getPlayerHtmlString(clipId: String, scrolling: Bool?, autoplay: Bool?, muted: Bool?,
                                     allowsFullScreen: Bool?) -> String {
        var currentPlayerParameters = [String]()

        if let allowsFullScreen = allowsFullScreen {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.allowsFullScreen, forValue: allowsFullScreen))
        }

        return TwitchClipPlayer.playerHtmlContent
            .replacingOccurrences(
                of: TwitchClipPlayer.initializationReplacementKey,
                with: currentPlayerParameters.joined(separator: TwitchClipPlayer.htmlParameterDelimiter))
    }

    /// `getHtmlParameterFormat` is used to convert a key-value mapping to its corresponding HTML format.
    ///
    /// This format is `key="value"`.
    ///
    /// - Parameters:
    ///   - key: The key of the relationship
    ///   - value: The value of the relationship
    /// - Returns: The key and value put together in HTML-Parameterized format
    private func getJsonParameterFormat(forKey key: String, forValue value: Any) -> String {
        return "\(key)\(TwitchClipPlayer.htmlKeyValueDelimiter)\"\(value)\""
    }
}
