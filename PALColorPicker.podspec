#
# Be sure to run `pod lib lint PALColorPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PALColorPicker'
  s.version          = '0.1.1'
  s.summary          = 'PALColorPicker'
  s.description      = <<-DESC
This is My Lib
                       DESC
  s.homepage         = 'https://github.com/pikachu987/PALColorPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pikachu987' => 'pikachu77769@gmail.com' }
  s.source           = { :git => 'https://github.com/pikachu987/PALColorPicker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'PALColorPicker/Classes/**/*'
  s.swift_version = '5.0'
end
