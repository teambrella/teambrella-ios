# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

def networking_pods
  pod 'Alamofire', '~> 4.4'
end

def formatter_pods
  pod 'SwiftyJSON'
end

def service_pods
  pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec'
end

target 'Teambrella' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  networking_pods
  formatter_pods
  #service_pods

  target 'TeambrellaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TeambrellaUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
