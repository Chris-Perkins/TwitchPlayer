#
# Be sure to run `pod lib lint TwitchPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TwitchPlayer'
  s.version          = '0.1.0'
  s.summary          = 'Embed Twitch Videos, Clips, Streams, and Collections.'

  s.description      = <<-DESC
TwitchPlayer is a library that is used to help you integrate Twitch Videos, Streams, Clips, and Collections directly into your application without you having to worry about any of the details.
                       DESC

  s.homepage         = 'https://github.com/Chris-Perkins/TwitchPlayer'
  s.screenshots     = 'https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/StreamPlay.png', 'https://github.com/Chris-Perkins/TwitchPlayer/raw/master/Readme_Imgs/ClipPlay.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chris Perkins' => 'chrisfromtemporaryid@gmail.com' }
  s.source           = { :git => 'https://github.com/Chris-Perkins/TwitchPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.linkedin.com/in/chrispperkins/'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = 'TwitchPlayer/Classes/**/*'
  s.frameworks = 'WebKit'
end
