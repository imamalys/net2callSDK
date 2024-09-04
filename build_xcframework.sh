# 1
xcodebuild archive \
-project Net2CallSDK.xcodeproj \
-scheme Net2CallSDK \
-sdk iphoneos \
-archivePath archives/ios_devices.xcarchive \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \

# 2
xcodebuild archive \
-project Net2CallSDK.xcodeproj \
-scheme Net2CallSDK \
-sdk iphonesimulator \
-archivePath archives/ios_simulators.xcarchive \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \

# 3
xcodebuild \
-create-xcframework \
-framework archives/ios_devices.xcarchive/Products/Library/Frameworks/Net2CallSDK.framework \
-framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/Net2CallSDK.framework \
-output Net2CallSDK.xcframework