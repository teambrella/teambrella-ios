# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

def service_pods
  pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec'
end

def social_pods
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
end

target 'Teambrella' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  #use_frameworks!
  inhibit_all_warnings!

  service_pods
  social_pods

  target 'TeambrellaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TeambrellaUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
