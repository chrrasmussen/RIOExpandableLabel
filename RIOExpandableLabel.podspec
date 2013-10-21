#
# Be sure to run `pod spec lint RIOExpandableLabel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "RIOExpandableLabel"
  s.version      = "0.0.2"
  s.summary      = "A label with a More-button to expand the text."
  s.homepage     = "https://github.com/chrrasmussen/RIOExpandableLabel"
  s.license      = 'MIT'
  s.author       = { "Christian Rasmussen" => "christian.rasmussen@me.com" }
  s.source       = { :git => "https://github.com/chrrasmussen/RIOExpandableLabel.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.source_files = 'RIOExpandableLabel/*.{h,m}'
  s.requires_arc = true
end
