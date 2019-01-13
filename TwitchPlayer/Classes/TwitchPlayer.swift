//
//  TwitchPlayer.swift
//  TwitchPlayer
//
//  Created by Christopher Perkins on 1/13/19.
//

import WebKit

/// `TwitchPlayer` is an embeddable Twitch Web Player. You can play Twitch Streams, Videos, and Clips from a
/// `TwitchPlayer` instance.
@IBDesignable public class TwitchPlayer: WKWebView {

    /// `PlayerTheme` specifies the potential color themes of a Twitch Player instance.
    ///
    /// - light: A Light theme
    /// - dark: A dark theme
    public enum PlayerTheme: String {
        case light
        case dark
    }

    /// `ChatDisplayMode` specifies the types of Chat display methods there are for Twitch chat.
    ///
    /// - defaultMode: Full-featured chat
    /// - mobile: Mobile-style chat
    public enum ChatDisplayMode: String {
        case defaultMode = "default"
        case mobile
    }

    /// `PlayerChatFontSize` specifies the different sizes of fonts that are available for Twitch players.
    ///
    /// - small: A small font size
    /// - medium: A font sized between the `small` and `large` font sizes
    /// - large: A large font size
    public enum PlayerChatFontSize: String {
        case small
        case medium
        case large
    }

    /// `PlayerLayout` specifies the different types of layouts that are available for an embedded Twitch Player.
    ///
    /// - videoWithChat: Specifies that a video with chat should be shown
    /// - videoOnly: Specifies that only the video should be shown
    public enum PlayerLayout: String {
        case videoWithChat = "video-with-chat"
        case videoOnly = "video"
    }

    /// `PlayerInitializationKeys` specifies the different keys that are a part of initialization for a Twitch Player.
    private struct PlayerInitializationKeys {
        internal static let channel = "channel"
        internal static let allowsFullScreen = "allowfullscreen"
        internal static let chatMode = "chat"
        internal static let collection = "collection"
        internal static let fontSize = "font-size"
        internal static let height = "height"
        internal static let layout = "layout"
        internal static let theme = "theme"
        internal static let video = "video"
        internal static let width = "width"

        /// Uninitializable
        private init() { }
    }

    /// `jsonParameterDelimiter` is used to delimiter different parameters in JSON.
    private static let jsonParameterDelimiter = ","

    /// `jsonKeyValueDelimiter` is used to delimit a JSON value and a key.
    private static let jsonKeyValueDelimiter = ":"

    /// `twitchPlayerHTMLName` specifies the variable name of the Twitch HTML player in the `playerHtmlContent` String.
    private static let twitchPlayerHTMLName = "player"

    /// `initializationReplacementKey` specifies the String that should be replaced in `playerHtmlContent` in order to
    /// add additional initialization properties.
    private static let initializationReplacementKey = "{0}"

    /// `playerHtmlContent` holds the HTML Content as a String regarding a Twitch Embedded player.
    private static let playerHtmlContent =
"""
<html><body><div id='twitch-embed' /><script src='https://embed.twitch.tv/embed/v1.js'></script><script type='text/javascript'>
const player = new Twitch.Embed('twitch-embed', {
    width: '100%',
    height: '100%',
    {0}
});
</script></body></html>
"""

    /// `showsChatPanel` specifies if the chat panel is shown.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `playerLayout` instead.
    @IBInspectable private(set) var showingChatPanel: Bool = false {
        didSet {
            playerLayout = showingChatPanel ? .videoWithChat : .videoOnly
        }
    }

    /// `chatModeIsMobile` is a read-only variable that specifies if this player's chat mode is mobile.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `chatMode` instead.
    @IBInspectable private(set) var chatModeIsMobile: Bool = true {
        didSet {
            chatMode = chatModeIsMobile ? .mobile : .defaultMode
        }
    }

    /// `playerThemeIsDark` specifies if this player's theme is the dark mode.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `playerTheme` instead.
    @IBInspectable private(set) var playerThemeIsDark: Bool = true {
        didSet {
            playerTheme = playerThemeIsDark ? .dark : .light
        }
    }

    /// `allowsFullScreen` is a settable variable that determines if the Twitch Player allows full screen.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    @IBInspectable public var allowsFullScreen: Bool = true {
        didSet {
            updateWebPlayer()
        }
    }

    /// `chatMode` is a settable variable that determines the mode of the chat display for the Twitch Player.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    public var chatMode: ChatDisplayMode? {
        didSet {
            updateWebPlayer()
        }
    }

    /// `playerLayout` is a settable variable that determines the layout of the Twitch Player.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    public var playerLayout: PlayerLayout? {
        didSet {
            updateWebPlayer()
        }
    }

    /// `playerTheme` is a settable variable that determines if the Web Player allows full screen.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    public var playerTheme: PlayerTheme? {
        didSet {
            updateWebPlayer()
        }
    }

    /// `videoToLoad` specifies the video that should be loaded.
    @IBInspectable private(set) var videoToLoad: String? = nil

    /// `channelId` specifies the name of the channel that should be watched.
    @IBInspectable var channelToLoad: String? {
        didSet {
            updateWebPlayer()
        }
    }

    /// `collectionToLoad` specifies the collection that should be loaded.
    ///
    /// - Warning: You **must** specify `videoToLoad` or the player will not work.
    @IBInspectable var collectionToLoad: String?

    init(channelToLoad: String? = "monstercat", videoToLoad: String?, collectionToLoad: String?,
         playerLayout: PlayerLayout?, chatMode: ChatDisplayMode? = .mobile,
         allowsFullScreen: Bool = true, playerTheme: PlayerTheme? = .dark, frame: CGRect,
         configuration: WKWebViewConfiguration) {
        // Set read-only variables so they match
        self.showingChatPanel = playerLayout == .videoWithChat
        self.chatModeIsMobile = chatMode != nil && chatMode! == .mobile
        self.playerThemeIsDark = playerTheme == .dark

        // player-specifying values
        self.videoToLoad = videoToLoad
        self.collectionToLoad = collectionToLoad
        self.channelToLoad = channelToLoad
        self.allowsFullScreen = allowsFullScreen
        self.chatMode = chatMode
        self.playerTheme = playerTheme
        self.playerLayout = playerLayout

        super.init(frame: frame, configuration: configuration)

        updateWebPlayer()
    }

    /// Initializes a TwitchPlayer with the specified frame and configuration.
    ///
    /// - Parameters:
    ///   - frame: The frame to initialize with
    ///   - configuration: The configuration to initialize with
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        updateWebPlayer()
    }

    /// Initializes a `TwitchPlayer` from the Storyboard.
    ///
    /// - Parameter coder: The NSCoder to initialize from
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        updateWebPlayer()
    }

    /// `updateWebPlayer` will update the loaded Twitch Player with the current parameters of the Twitch Player.
    private func updateWebPlayer() {
        let playerHtml = getPlayerHtmlString(channelToLoad: channelToLoad, videoToLoad: videoToLoad,
                                             collectionToLoad: collectionToLoad, playerLayout: playerLayout,
                                             chatMode: chatMode, fontSize: nil, playerTheme: playerTheme,
                                             allowsFullScreen: allowsFullScreen)
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
    private func getPlayerHtmlString(channelToLoad: String?, videoToLoad: String?, collectionToLoad: String?,
                                     playerLayout: PlayerLayout?, chatMode: ChatDisplayMode?,
                                     fontSize: PlayerChatFontSize?, playerTheme: PlayerTheme?,
                                     allowsFullScreen: Bool?) -> String {
        var currentPlayerParameters = [String]()

        if let channelToLoad = channelToLoad {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.channel, forValue: channelToLoad))
        }
        if let videoToLoad = videoToLoad {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.video, forValue: videoToLoad))
        }
        if let collectionToLoad = collectionToLoad {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.collection, forValue: collectionToLoad))
        }
        if let playerLayout = playerLayout {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.layout, forValue: playerLayout.rawValue))
        }
        if let chatMode = chatMode {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.chatMode, forValue: chatMode.rawValue))
        }
        if let fontSize = fontSize {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.fontSize, forValue: fontSize.rawValue))
        }
        if let playerTheme = playerTheme {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.theme, forValue: playerTheme.rawValue))
        }
        if let allowsFullScreen = allowsFullScreen {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: PlayerInitializationKeys.allowsFullScreen, forValue: allowsFullScreen,
                                       isStringValued: false))
        }

        return TwitchPlayer.playerHtmlContent
            .replacingOccurrences(of: TwitchPlayer.initializationReplacementKey,
                                  with: currentPlayerParameters.joined(separator: TwitchPlayer.jsonParameterDelimiter))
    }

    /// `getJsonParameterFormat` is used to convert a key-value mapping to its corresponding JSON format.
    ///
    /// This format is `key: "value"`.
    ///
    /// - Parameters:
    ///   - key: The key of the relationship
    ///   - value: The value of the relationship
    /// - Returns: The key and value put together in JSON-Parameterized format
    private func getJsonParameterFormat(forKey key: String, forValue value: Any,
                                        isStringValued: Bool = true) -> String {
        return isStringValued ? "\(key)\(TwitchPlayer.jsonKeyValueDelimiter) \"\(value)\""
            : "\(key)\(TwitchPlayer.jsonKeyValueDelimiter) \(value)"
    }
}
