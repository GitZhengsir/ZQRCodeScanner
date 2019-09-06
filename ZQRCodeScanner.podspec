#
#  Be sure to run `pod spec lint ZQRCodeScanner.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ZQRCodeScanner"
  spec.version      = "1.0"
  spec.summary      = "A simple QR code scanner for personal use."
  spec.homepage     = "https://github.com/GitZhengsir/ZQRCodeScanner"
  spec.license      = "MIT"
  spec.author       = { "zhengsir" => "276929275@qq.com" }
  spec.source       = { :git => "https://github.com/GitZhengsir/ZQRCodeScanner.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "ZQRCodeScanner/*.{h,m}"
  spec.resource_bundles = {
    "ZQRCodeScanner" => ["ZQRCodeScanner/*.png"],
  }

  spec.requires_arc = true
  spec.frameworks   = 'UIKit' 
  spec.ios.deployment_target  = '8.0'
end
