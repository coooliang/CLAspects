#
# Be sure to run `pod lib lint CLAspects.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CLAspects'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CLAspects.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/coooliang/CLAspects'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chenliang' => 'lion' }
  s.source           = { :git => 'https://github.com/CocoaPods/Specs.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.source_files = 'CLAspects/Classes/**/*'
  s.dependency 'Aspects','1.4.1'
  s.dependency 'XlsxReaderWriter', '1.0.11'
end
