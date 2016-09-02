platform :ios, '9.3'
use_frameworks!

target 'Mesh'

pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => '3cc5b4e8453bec9fd6b973d60e6b0605a38e4cf4'
#pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'AlamofireImage', :git => 'https://github.com/Alamofire/AlamofireImage.git', :commit => 'b02916e89cb7158994df04bf282b3170964e1eaa'

pod 'JSQMessagesViewController'#, :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :commit => 'e919ff9e509b36e1d6e9e70d7197932a713bd625'
#pod 'MGSwipeTableCell'
#pod 'Shimmer'

#pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master', :submodules => 'true'
#pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :branch => 'swift3'

pod 'TwitterKit'
pod 'TwitterCore'
pod 'Fabric'

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

