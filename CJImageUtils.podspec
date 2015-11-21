#
# Be sure to run `pod lib lint CJWaterfallLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CJImageUtils"
  s.version          = "1.0.5"
  s.summary          = "A lightweight library for downloading and caching image from the web. It is implemented purely in swift."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                      A lightweight library for downloading and caching image from the web. It is implemented purely in swift. This project is heavily inspired by the SDWebImage and Kingfisher library.
                       DESC

  s.homepage         = "https://github.com/jie-cao/CJImageUtils"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jie" => "jie_cao@hotmail.com" }
  s.source           = { :git => "https://github.com/jie-cao/CJImageUtils.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'CJImageUtils/*.swift'
  #s.resource_bundles = {
  #  'CJImageUtils' => ['Pod/Assets/*.png']
  #}

  s.frameworks = 'Foundation', 'UIKit'
end
