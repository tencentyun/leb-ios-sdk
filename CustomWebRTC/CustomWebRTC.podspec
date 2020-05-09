
Pod::Spec.new do |s|

  s.name         = "CustomWebRTC"
  s.summary      = "A short description of CustomWebRTC."

  s.homepage     = "https://github.com/tencentyun/leb-ios-sdk.git"

  s.license      = "MIT"

  s.author             = { "tstan" => "tstan@tencent.com" }
  s.version = "1.0.0"
  s.platform     = :ios
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/tencentyun/leb-ios-sdk.git", :tag => "#{s.version}" }

 s.source_files  = "WebRTC.framework/Headers/*.h"
  # s.exclude_files = "Classes/Exclude"

  s.public_header_files = "WebRTC.framework/Headers/*.h"

  s.vendored_frameworks = 'WebRTC.framework'

  s.requires_arc = true
end
