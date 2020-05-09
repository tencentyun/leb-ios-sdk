
Pod::Spec.new do |s|

  s.name         = "LiveEB_IOS"
  s.version      = "0.0.1"
  s.summary      = "A short description of LiveEB_IOS."

  s.homepage     = "https://github.com/tencentyun/LiveEB_IOS.git"

  s.license      = "MIT"

  s.author             = { "tstan" => "tstan@tencent.com" }
  s.version = "1.0.0"
  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/tencentyun/LiveEB_IOS.git", :tag => "#{s.version}" }

  s.source_files  = "LiveEB_IOS", "LiveEB_IOS/**/*.{h,m,mm}"
  s.exclude_files = "LiveEB_IOS/Protocols/*.{h,m}"
  s.static_framework=false

  s.requires_arc = true

  s.dependency "TWebRTC"
end
