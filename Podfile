# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
use_frameworks!
use_modular_headers!
inhibit_all_warnings!

def bitcoin_pods
  pod 'CoreEthereum', :podspec => 'https://raw.github.com/teambrella/CoreEthereum/master/CoreEthereum.podspec', :modular_headers => false
end

def ethereum_pods
  pod 'Geth', '~> 1.7'
end

def social_pods
    #  pod 'FBSDKCoreKit'
    #  pod 'FBSDKLoginKit'

    #  pod 'Auth0', '~> 1.0'
    #  pod 'SimpleKeychain' # dependency for the Auth0
end

def firebase_pods
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/DynamicLinks'
end

def swift_frameworks_pods
  pod 'SwiftSoup'
  pod 'XLPagerTabStrip', :git => 'https://github.com/xmartlabs/XLPagerTabStrip.git'#, :commit => '4fe566f187b7e2c7c883a438bc6ab701a81ebbb3'
  pod 'ImageSlideshow'
  pod 'KeychainAccess'
  pod 'Kingfisher'
  pod 'PKHUD'
  pod 'ReachabilitySwift'
  pod 'QRCode'
  pod 'Starscream'
  pod 'SwiftDate'
  pod 'SwiftMessages', '~> 5.0'
  #  pod 'MessengerKit', :git => 'https://github.com/steve228uk/MessengerKit.git'

  pod 'Fabric'
  pod 'Crashlytics'

  pod 'SinchRTC'
  #  pod 'UXCam'
  pod 'AppsFlyerFramework'

  pod 'BigNumber', :git => 'https://github.com/mkrd/Swift-Big-Integer.git'
  pod 'ExtensionsPack', :git => 'https://github.com/yaro812/ExtensionsPack.git'
  pod 'ThoraxMath', :git => 'https://github.com/yaro812/ThoraxMath.git'
  pod 'SwiftEmail', :git => 'https://github.com/yaro812/SwiftEmail.git'
  
end

def notification_swift_pods
  bitcoin_pods
  #ethereum_pods
  pod 'Kingfisher'
  pod 'KeychainAccess'
  pod 'ExtensionsPack', :git => 'https://github.com/yaro812/ExtensionsPack.git'
end

def pods_bundle
  bitcoin_pods
  ethereum_pods
  social_pods
  firebase_pods
  swift_frameworks_pods
end

target 'Surilla' do
  pods_bundle
end

target 'Teambrella' do
    pods_bundle

    target 'TeambrellaTests' do
        inherit! :search_paths
    end

#    target 'TeambrellaUITests' do
#        inherit! :search_paths
#    end
end

pod 'JustLog'

target 'SurillaNotification' do
  notification_swift_pods
end

target 'TeambrellaNotification' do
  notification_swift_pods
end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['ARCHS'] = 'arm64'
#    end
#  end
#end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
