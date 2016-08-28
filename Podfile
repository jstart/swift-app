platform :ios, '10101010101010101010.0'
use_frameworks!

target 'Mesh'

pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => '1dc3992a3854ca369368c8997ea3c45054070e67'
#pod 'AlamofireImage', :git => 'https://github.com/Alamofire/AlamofireImage.git', :branch => 'swift3'
pod 'JSQMessagesViewController'
#pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master', :submodules => 'true'
pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :branch => 'swift3'

pod 'TwitterKit'
pod 'TwitterCore'
pod 'Fabric'

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
	        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
            config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

