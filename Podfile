platform :ios, '9.3'
use_frameworks!

target 'Mesh'

pod 'Alamofire'
pod 'AlamofireImage'
#pod 'SwiftyJSON'

pod 'JSQMessagesViewController', :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :commit => 'bbc6d27a483388a4c6413fc63bbf9c367054be21'
#pod 'SkyFloatingLabelTextField'
#pod 'MGSwipeTableCell'

pod 'OAuthSwift', :git => 'https://github.com/jstart/OAuthSwift.git', :branch => 'patch-1'
#pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :branch => 'swift3'
#pod 'NearbyMessages'
pod 'TwitterKit'
pod 'TwitterCore'
pod 'GoogleSignIn'
#pod 'LinkedinSwift', '~> 1.6.6'

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

