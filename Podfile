# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

def bitcoin_pods
  pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec'
end

def ethereum_pods
  pod 'Geth', '~> 1.7'
end

def social_pods
  pod 'FBSDKCoreKit', :modular_headers => true
  pod 'FBSDKLoginKit', :modular_headers => true
end

def firebase_pods
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end

def swift_frameworks_pods
  pod 'SwiftSoup'
  #pod 'XLPagerTabStrip'
  pod 'ImageSlideshow'
  pod 'KeychainAccess'
  pod 'Kingfisher'
 #pod 'PKHUD'
  pod 'ReachabilitySwift'
  pod 'QRCode', :modular_headers => true
  pod 'Starscream'
  pod 'SwiftDate'
  pod 'SwiftMessages'

  pod 'BigNumber', :git => 'https://github.com/mkrd/Swift-Big-Integer.git'
  pod 'ExtensionsPack', :git => 'https://github.com/yaro812/ExtensionsPack.git'
  pod 'ThoraxMath', :git => 'https://github.com/yaro812/ThoraxMath.git'
end

def notification_swift_pods
  bitcoin_pods
  #ethereum_pods
  pod 'Kingfisher'
  pod 'KeychainAccess'
  #pod 'Starscream'
  #pod 'BigNumber', :git => 'https://github.com/mkrd/Swift-Big-Integer.git'
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
  inhibit_all_warnings!

  pods_bundle

end

target 'Teambrella' do
    inhibit_all_warnings!

    pods_bundle

    target 'TeambrellaTests' do
        inherit! :search_paths

    end

end

target 'notification' do
  inhibit_all_warnings!

  notification_swift_pods

end

target 'NotificationTeambrella' do
  inhibit_all_warnings!

  notification_swift_pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = 'arm64'
    end
  end
end
