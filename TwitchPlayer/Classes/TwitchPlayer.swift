//
//  TwitchPlayer.swift
//  TwitchPlayer
//
//  Created by Christopher Perkins on 1/13/19.
//

import WebKit

/// `TwitchPlayer` is an embeddable Twitch Web Player. You can play Twitch Streams and Videos from a `TwitchPlayer`
/// instance.
///
/// You can edit the following properties of the TwitchPlayer from the Storyboard and an Initializing function:
/// * Layout
/// * Theme
/// * Chat Mode
/// * Allows Full Screen
/// * Channel To View
/// * Video To View
/// * Collection to View
///
/// You can edit the following after the TwitchPlayer loads successfully:
/// * viewedChannel - `setChannel(to: String)`
/// * viewedVideo - `setVideo(to: String, timestamp: Float)`
/// * viewedCollection - `setCollection(to: String, videoId: String)`
/// * volume - `setVolume(to: Float)`
/// * pause state - `pause()`, `play()`, `togglePlaybackState()`
///
/// - Note: You **cannot** load a Twitch Clip from this class.
@IBDesignable public class TwitchPlayer: WKWebView {

    // MARK: - Custom Data Types

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

    // MARK: - Static Members

    /// `isWebViewBackgroundOpaque` specifies whether the background of the web view this Clip Player is hosted in is
    /// opaque or not.
    private static let isWebViewBackgroundOpaque = false

    /// `isWebViewScrollEnabled` specifies whether the web view this Clip Player is hosted in is scrollable or not.
    private static let isWebViewScrollEnabled = false

    /// `jsonParameterDelimiter` is used to delimiter different parameters in JSON.
    private static let jsonParameterDelimiter = ","

    /// `jsonKeyValueDelimiter` is used to delimit a JSON value and a key.
    private static let jsonKeyValueDelimiter = ":"

    /// `initializationReplacementKey` specifies the String that should be replaced in `playerHtmlContent` in order to
    /// add additional initialization properties.
    private static let initializationReplacementKey = "{0}"

    /// `playerHtmlContent` holds the HTML Content as a String regarding a Twitch Embedded player.
    private static let playerHtmlContent =
"""
<meta name="viewport" content="initial-scale=1.0" />
<html>
    <body>
        <div id='twitch-embed' />
        <script src='https://embed.twitch.tv/embed/v1.js'></script><script type='text/javascript'>
            var playerCommandsToExecute = [];
            var player = null;

            const embed = new Twitch.Embed('twitch-embed', {
                width: '100%',
                height: '95%',
                playsinline: true,
                {0}
            });

            embed.addEventListener(Twitch.Embed.VIDEO_READY, () => {
                player = embed.getPlayer();
                player.play();
                
                playerCommandsToExecute.forEach(function(playerCommand) {
                    playerCommand();
                });
                playerCommandsToExecute = [];
            });

            function performPlayerCommand(command) {
                if (player == null) {
                    playerCommandsToExecute.push(command);
                } else {
                    command();
                }
            }
        </script>
    </body>
</html>
"""

    /// `videoToLoad` specifies the video that should be loaded.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization. To avoid this behavior, please use the `setVideo` method.
    @IBInspectable private(set) var videoToLoad: String? {
        didSet {
            updateWebPlayer()
        }
    }

    /// `channelId` specifies the name of the channel that should be watched.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization. To avoid this behavior, please use the `setChannel` method.
    @IBInspectable private(set) var channelToLoad: String? {
        didSet {
            updateWebPlayer()
        }
    }
    
    /// `collectionToLoad` specifies the collection that should be loaded.
    ///
    /// - Warning: You **must** specify `videoToLoad` or the player will not work.
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization. To avoid this behavior, please use the `setCollection` method.
    @IBInspectable private(set) var collectionToLoad: String? {
        didSet {
            updateWebPlayer()
        }
    }
    
    /// `showsChatPanel` specifies if the chat panel is shown.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `playerLayout` instead.
    @IBInspectable private var showingChatPanel: Bool = false {
        didSet {
            playerLayout = showingChatPanel ? .videoWithChat : .videoOnly
        }
    }

    /// `chatModeIsMobile` is a read-only variable that specifies if this player's chat mode is mobile.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `chatMode` instead.
    @IBInspectable private var chatModeIsMobile: Bool = true {
        didSet {
            chatMode = chatModeIsMobile ? .mobile : .defaultMode
        }
    }

    /// `playerThemeIsDark` specifies if this player's theme is the dark mode.
    ///
    /// - Warning: This variable is only for initialization. For correct values, please use `playerTheme` instead.
    @IBInspectable private var playerThemeIsDark: Bool = true {
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
    public var chatMode: ChatDisplayMode? = .mobile {
        didSet {
            updateWebPlayer()
        }
    }

    /// `playerLayout` is a settable variable that determines the layout of the Twitch Player.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    public var playerLayout: PlayerLayout? = .videoOnly {
        didSet {
            updateWebPlayer()
        }
    }

    /// `playerTheme` is a settable variable that determines if the Web Player allows full screen.
    ///
    /// - Warning: Setting this reloads the Web Player. This may cause un-polished behavior, and generally should
    /// not be done after initialization.
    public var playerTheme: PlayerTheme? = .dark {
        didSet {
            updateWebPlayer()
        }
    }

    /// Initializes a Twitch Player with the input parameters
    ///
    /// - Parameters:
    ///   - channelToLoad: The name of the channel to load; leave blank if `videoToLoad` or `collectionToLoad` is
    /// specified.
    ///   - videoToLoad: The ID of the video to load; leave blank if `channelToLoad` is specified.
    ///   - collectionToLoad: The ID of the collection to load; leave blank if `channelToLoad` is specified.
    ///   - playerLayout: The layout of the player
    ///   - chatMode: The mode of the chat
    ///   - allowsFullScreen: Whether or not the player allows full screen
    ///   - playerTheme: The theme of the player
    ///   - frame: The frame of the player
    ///   - configuration: The configuration for the web view
    init(channelToLoad: String?, videoToLoad: String?, collectionToLoad: String?,
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

        scrollView.isScrollEnabled = TwitchPlayer.isWebViewScrollEnabled
        isOpaque = TwitchPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    /// Initializes a TwitchPlayer with the specified frame and configuration.
    ///
    /// - Parameters:
    ///   - frame: The frame to initialize with
    ///   - configuration: The configuration to initialize with
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        scrollView.isScrollEnabled = TwitchPlayer.isWebViewScrollEnabled
        isOpaque = TwitchPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    /// Initializes a `TwitchPlayer` from the Storyboard.
    ///
    /// - Parameter coder: The NSCoder to initialize from
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        scrollView.isScrollEnabled = TwitchPlayer.isWebViewScrollEnabled
        isOpaque = TwitchPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    // MARK: - Web Player Interaction Functions

    /// `pause` pauses the Twitch Player. Note that this does *not* toggle the pause state; this command will only ever
    /// pause the player. To toggle playback, please see `togglePlaybackState`.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func pause() {
        evaluateJavaScript("performPlayerCommand(function() { player.pause(); })")
    }

    /// `play` will cause the Twitch Player to play. Note that this does *not* toggle the playback state; this
    /// command will only ever cause the player to play. To toggle playback, please see `togglePlaybackState`.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func play() {
        evaluateJavaScript("performPlayerCommand(function() { player.play(); })")
    }

    /// `togglePlaybackState` will toggle the current play state of the embedded Twitch Player. I.e. if the player is
    /// paused, it will play. If the player is playing, it will pause it.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func togglePlaybackState() {
        evaluateJavaScript(
            "performPlayerCommand(function() { if (player.isPaused()) { player.play(); } else { player.pause(); } })")
    }

    /// `setVolume` sets the volume level of the Twitch Player to the input value.
    ///
    /// - Parameter volumeLevel: The level to set the volume to. 0 = muted, 1.0 = maximum.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func setVolume(to volumeLevel: Float) {
        evaluateJavaScript("performPlayerCommand(function() { player.setVolume(\(volumeLevel)); })")
    }

    /// `setVideo` sets the video to be played in the Twitch Player. This will change the currently viewed item to the
    /// input video.
    ///
    /// - Parameters:
    ///   - videoId: The video to load
    ///   - timestamp: The timestamp of the video to jump to
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func setVideo(to videoId: String, timestamp: Float) {
        evaluateJavaScript("performPlayerCommand(function() { player.setVideo(\"\(videoId)\", \(timestamp)); })")
    }

    /// `setChannel` sets the channel to be played in the Twitch Player. This will change the currently viewed item
    /// to the new channel.
    ///
    /// - Parameter streamName: The name of the stream to load
    public func setChannel(to streamName: String) {
        evaluateJavaScript("performPlayerCommand(function() { player.setChannel(\"\(streamName)\"); })")
    }

    /// `setCollection` sets the currently viewed collection to be played in the Twitch Player. This will change
    /// the currently viewed item to the collection.
    ///
    /// - Parameters:
    ///   - collectionId: The collection to watch
    ///   - videoId: The ID of the video to watch
    public func setCollection(to collectionId: String, videoId: String) {
        evaluateJavaScript(
            "performPlayerCommand(function() { player.setCollection(\"\(collectionId)\", \"\(videoId)\"); })")
    }

    /*
     //The below lines are commented as they do not appear to work, but they are kept in case they work some day.
    /// `mute` will mute the Twitch Player.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func mute() {
        evaluateJavaScript("performPlayerCommand(function() { player.setMuted(true); })")
    }

    /// `unmute` will unmute the Twitch Player.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func unmute() {
        evaluateJavaScript("performPlayerCommand(function() { player.setMuted(false); })")
    }

    /// `toggleMute` will toggle the mute state of the Twitch Player.
    ///
    /// - Note: This function will not run successfully before the HTML of the web view is loaded.
    public func toggleMute() {
        evaluateJavaScript("performPlayerCommand(function() { player.setMuted(!player.getMuted()); })")
    }
    */

    // MARK: - Web Player Loading Functions

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
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.channel, forValue: channelToLoad))
        }
        if let videoToLoad = videoToLoad {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.video, forValue: videoToLoad))
        }
        if let collectionToLoad = collectionToLoad {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.collection, forValue: collectionToLoad))
        }
        if let playerLayout = playerLayout {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.layout, forValue: playerLayout.rawValue))
        }
        if let chatMode = chatMode {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.chatMode, forValue: chatMode.rawValue))
        }
        if let fontSize = fontSize {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.fontSize, forValue: fontSize.rawValue))
        }
        if let playerTheme = playerTheme {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.theme, forValue: playerTheme.rawValue))
        }
        if let allowsFullScreen = allowsFullScreen {
            currentPlayerParameters.append(
                getJsonParameterFormat(forKey: TwitchWebPlayerKeys.allowsFullScreen, forValue: allowsFullScreen,
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
