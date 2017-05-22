//
//  AppDelegate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //style()
        return true
    }
    
    func style() {
       let view = UIView.appearance(whenContainedInInstancesOf: [UIWindow.self])
        view.backgroundColor = .teambrellaBlue
        
        let label = UILabel.appearance()
        label.textColor = .white
        label.backgroundColor = .clear
        
        let button = UIButton.appearance()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = .teambrellaBlue
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let tabBar = UITabBar.appearance()
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .teambrellaBlue
        tabBar.tintColor = .white
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                            open: url,
                                                                            sourceApplication: sourceApplication,
                                                                            annotation: annotation)
    }

}
