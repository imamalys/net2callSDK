Pod::Spec.new do |s|
  s.name         = "Net2CallSDK"
  s.version      = "1.0"
  s.summary      = "Net2Call is a library to apps based on SIP protocol."
  s.description  = <<-PODSPEC_DESC
Net2Call is a library to apps based on SIP protocol.
PODSPEC_DESC
s.homepage         = 'https://github.com/imamalys/net2callSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Net2CallSDK' => 'Net2CallSDK' }
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/imamalys/net2callSDK.git", :tag => 'v1.0' }
  s.frameworks = "Net2CallSDK.xcframework"
  s.pod_target_xcconfig = { 'VALID_ARCHS' => "arm64 x86_64" }
  s.user_target_xcconfig = { 'VALID_ARCHS' => "arm64 x86_64" }
  s.module_name   = 'Net2CallSDK' # name of the swift package
  s.swift_version = '5.0'
  s.dependency 'SnapKit', '~> 5.6.0'
end
