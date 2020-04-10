
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

 s.source_files  = "Product/LiveEB_IOS.framework/Headers/*.h"
  # s.exclude_files = "Classes/Exclude"

  s.public_header_files = "Product/LiveEB_IOS.framework/Headers/*.h"

  s.vendored_frameworks = 'Product/LiveEB_IOS.framework'

  s.requires_arc = true

  s.dependency "GoogleWebRTC", '1.1.26465'

end
