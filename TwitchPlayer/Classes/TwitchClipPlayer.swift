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
/// * `clipId` - The ID of the Clip to Play
/// * `scrollingEnabled`: Whether or not scroll is enabled on this clip
/// * `autoPlayEnabled`: Whether or not the clip will autoplay on initialization
/// * `muteOnLoad`: Whether or not the clip should be muted when it loads
/// * `preloadSetting`: Whether or not this clip should preload.
@IBDesignable public class TwitchClipPlayer: WKWebView {

    // MARK: - Custom Data Types

    /// `ScrollingValues` defines the different types of values that the `scrolling` attribute that a Twitch Clip Player
    /// can have.
    ///
    /// - yes: Scrolling is enabled
    /// - no: Scrolling is disabled
    private enum ScrollingValues: String {
        case yes
        case no
    }

    /// `PreloadSettings` defines the different types of settings that are available
    ///
    /// - none: No preloading should occur
    /// - metadata: Only clip metadata should be preloaded
    /// - auto: The clip will be preloaded
    public enum PreloadSettings: String {
        case none
        case metadata
        case auto
    }

    // MARK: - Static Members

    /// `isWebViewBackgroundOpaque` specifies whether the background of the web view this Clip Player is hosted in is
    /// opaque or not.
    private static let isWebViewBackgroundOpaque = false

    /// `isWebViewScrollEnabled` specifies whether the web view this Clip Player is hosted in is scrollable or not.
    private static let isWebViewScrollEnabled = false

    /// `htmlParameterDelimiter` is used to delimiter different parameters in HTML.
    private static let htmlParameterDelimiter = " "

    /// `htmlKeyValueDelimiter` is used to delimit a HTML key and value.
    private static let htmlKeyValueDelimiter = "="

    /// `initializationReplacementKey` specifies the String that should be replaced in `playerHtmlContent` to add
    /// additional initialization properties.
    private static let initializationReplacementKey = "{0}"

    /// `clipBaseUrlAsString` is the base URL of the embedded Twitch URL.
    private static let clipBaseUrlAsString = URL(string: "https://clips.twitch.tv/embed")!

    /// `playerHtmlContent` holds the HTML Content as a String regarding a Twitch Clip Embedded player.
    private static let playerHtmlContent =
"""
<meta name="viewport" content="initial-scale=1.0" />
<iframe
    height="95%"
    width="100%"
    frameborder="0"
    margin="0"
    padding="0"
    autoplay="false"
    preload="none"
    {0}
/>
"""

    // MARK: - IBInspectables

    /// `clipId` is a settable variable that determines which clip will be loaded in this clip player. Default: `""`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var clipId: String = "" {
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

    /// `allowsFullScreen` is a settable variable that determines if a Twitch Clip Player will allow full screen.
    /// Default: `true`
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    @IBInspectable public var allowsFullScreen: Bool = true {
        didSet {
            updateWebPlayer()
        }
    }

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

    /// `preloadEnabled` is an IBInspectable that will set `preloadSetting` upon set.
    @IBInspectable private var preloadEnabled: Bool = true {
        didSet {
            preloadSetting = preloadEnabled ? .auto : .none
        }
    }

    /// `preloadSetting` specifies whether or not this Clip Player should preload the loaded clip. Default: `.auto`.
    ///
    /// - Warning: Setting this reloads the Player. This may cause un-polished behavior, and generally should not be
    /// done after initialization.
    public var preloadSetting: PreloadSettings = .auto {
        didSet {
            updateWebPlayer()
        }
    }

    // MARK: - Life Cycle

    /// Initializes a Twitch Clip Player with the input parameters.
    ///
    /// - Parameters:
    ///   - clipId: The ID of the clip to load
    ///   - autoPlayEnabled: Whether or not the clip will autoplay on initialization. Default: `false`
    ///   - muteOnLoad: Whether or not the clip should be muted when it loads. Default: `true`
    ///   - allowsFullScreen: Whether or not full screen should be allowed.
    ///   - preloadSetting: Whether or not this Clip Player should pre-load the view. Default: `.auto`
    ///   - scrollEnabled: Whether or not scroll is enabled on this clip
    ///   - frame: The frame of the web view
    ///   - configuration: The configuration of the web view to host the clip in
    init(clipId: String, autoPlayEnabled: Bool = false, muteOnLoad: Bool = true, allowsFullScreen: Bool,
         preloadSetting: PreloadSettings = .auto, scrollEnabled: Bool, frame: CGRect,
         configuration: WKWebViewConfiguration) {
        self.clipId = clipId
        self.autoPlayEnabled = autoPlayEnabled
        self.muteOnLoad = muteOnLoad
        self.allowsFullScreen = allowsFullScreen
        self.preloadSetting = preloadSetting
        self.scrollingEnabled = scrollEnabled

        super.init(frame: frame, configuration: configuration)

        scrollView.isScrollEnabled = TwitchClipPlayer.isWebViewScrollEnabled
        isOpaque = TwitchClipPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    /// Initializes a TwitchPlayer with the specified frame and configuration.
    ///
    /// - Parameters:
    ///   - frame: The frame to initialize with
    ///   - configuration: The configuration to initialize with
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        scrollView.isScrollEnabled = TwitchClipPlayer.isWebViewScrollEnabled
        isOpaque = TwitchClipPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    /// Initializes a `TwitchPlayer` from the Storyboard.
    ///
    /// - Parameter coder: The NSCoder to initialize from
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        scrollView.isScrollEnabled = TwitchClipPlayer.isWebViewScrollEnabled
        isOpaque = TwitchClipPlayer.isWebViewBackgroundOpaque
        updateWebPlayer()
    }

    // MARK: - Clip Loading Functions

    /// `updateWebPlayer` will update the loaded Twitch Player with the current parameters of the Twitch Player.
    private func updateWebPlayer() {
        let playerHtml = getPlayerHtmlString(clipId: clipId, scrolling: scrollingEnabled ? .yes : .no,
                                             allowFullScreen: allowsFullScreen, preloadSetting: preloadSetting,
                                             autoplay: autoPlayEnabled, muted: muteOnLoad)
        loadHTMLString(playerHtml, baseURL: nil)
    }

    /// `getPlayerHtmlString` is used to get the HTML string that gets for an embedded iFrame Twitch Clip with the
    /// provided parameters.
    ///
    /// - Parameters:
    ///   - clipId: The ID of the clip to retrieve
    ///   - scrolling: The scroll setting for the clip
    ///   - allowsFullScreen: Whether or not fullscreen should be enabled
    ///   - preloadSetting: Specifies the type of preloading that should occur.
    ///   - autoplay: Whether or not the clip will autoplay
    ///   - muted: Whether or not the clip is muted
    /// - Returns: The HTML string that allows for embedded Twitch Clips.
    private func getPlayerHtmlString(clipId: String, scrolling: ScrollingValues, allowFullScreen: Bool,
                                     preloadSetting: PreloadSettings, autoplay: Bool?, muted: Bool?) -> String {
        var currentPlayerParameters = [String]()
        var currentPlayerQueryParameters = [String: String]()

        if let autoplay = autoplay {
            currentPlayerQueryParameters[TwitchWebPlayerKeys.autoplay] = "\(autoplay)"
        }
        if let muted = muted {
            currentPlayerQueryParameters[TwitchWebPlayerKeys.muted] = "\(muted)"
        }
        currentPlayerQueryParameters[TwitchWebPlayerKeys.allowsFullScreen] = "\(allowFullScreen)"
        currentPlayerQueryParameters[TwitchWebPlayerKeys.clip] = clipId
        let queriedUrl = TwitchClipPlayer.clipBaseUrlAsString.withQueryItems(currentPlayerQueryParameters)

        currentPlayerParameters.append(getHtmlParameterFormat(forKey: TwitchWebPlayerKeys.preload,
                                                              forValue: preloadSetting.rawValue))
        currentPlayerParameters.append(getHtmlParameterFormat(forKey: TwitchWebPlayerKeys.source,
                                                              forValue: queriedUrl.absoluteString))
        currentPlayerParameters.append(getHtmlParameterFormat(forKey: TwitchWebPlayerKeys.scrolling,
                                                              forValue: scrolling.rawValue))

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
    private func getHtmlParameterFormat(forKey key: String, forValue value: Any) -> String {
        return "\(key)\(TwitchClipPlayer.htmlKeyValueDelimiter)\"\(value)\""
    }
}
