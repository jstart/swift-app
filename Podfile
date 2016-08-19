platform :ios, '10101010101010101010.0'
use_frameworks!

target 'Mesh'

pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift3'
pod 'JSQMessagesViewController'

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
	        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
            config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

