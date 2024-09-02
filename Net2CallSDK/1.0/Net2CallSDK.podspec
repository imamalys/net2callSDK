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
  s.source       = { :git => "https://github.com/imamalys/net2callSDK.git", :tag => 'v1.2'}
  s.vendored_frameworks = "Net2CallSDK.xcframework"
  s.module_name   = 'Net2CallSDK' # name of the swift package
  s.swift_version = '5.0'
 s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
