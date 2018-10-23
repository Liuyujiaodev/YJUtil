#
#  Be sure to run `pod spec lint XQCategory.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name     = "YJUtil"
s.version  = "1.0.6"
s.license  = "MIT"
s.summary  = "iOS工具类"
s.homepage = "https://github.com/Liuyujiaodev/YJUtil.git"
s.author   = "liuyujiao"
#s.social_media_url = "https://www.jianshu.com/u/16227d25bcf4"
s.source       = { :git => "https://github.com/Liuyujiaodev/YJUtil.git", :tag => "#{s.version}" }
s.description = %{
。
}
s.source_files = "YJUtil/**/*.{h,m}"
s.frameworks = 'Foundation', 'UIKit','AdSupport','CoreTelephony','CoreLocation','Contacts','AddressBook'

s.dependency "Reachability"
s.dependency "YJBase64"
s.dependency "YJCategory"

s.requires_arc = true
s.platform = :ios, '8.0'
end
