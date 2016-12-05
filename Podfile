platform :ios, '9.3'
use_frameworks!

target 'Ripple'

pod 'Alamofire'
pod 'AlamofireImage'
#pod 'SwiftyJSON'
pod 'RealmSwift'

pod 'JSQMessagesViewController', :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :commit => '7cd699828efe12a5a1e26eaa51da9ff8736efefa'
#pod 'SkyFloatingLabelTextField'
#pod 'MGSwipeTableCell'

pod 'Socket.IO-Client-Swift'
#pod 'Starscream'
#pod 'NearbyMessages'
pod 'TwitterKit'
pod 'TwitterCore'
pod 'GoogleSignIn'
pod 'Firebase/Core'

pod 'Crashlytics'
pod 'Fabric'

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

