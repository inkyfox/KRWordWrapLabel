Pod::Spec.new do |s|
  s.name             = "KRWordWrapLabel"
  s.version          = "2.1.1"
  s.summary          = "UILabel subclass which provides **Word Wrap** based on white spaces not depending on languages"
  s.homepage         = "https://github.com/inkyfox/KRWordWrapLabel"
  s.screenshot       = "https://raw.githubusercontent.com/inkyfox/KRWordWrapLabel/master/screenshot/KRWordWrapLabel.gif"
  s.license          = 'MIT'
  s.author           = { "Yongha Yoo" => "inkyfox@oo-v.com" }
  s.platform         = :ios, "8.0"
  s.source           = { :git => "https://github.com/inkyfox/KRWordWrapLabel.git", :tag => s.version.to_s }
  s.framework        = "UIKit"
  s.requires_arc          = true
  s.ios.deployment_target = '8.0'
  s.source_files          = 'Sources/KRWordWrapLabel.swift'
  s.swift_version = '4.1'
end
