//
//  MainRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

final class MainRouter {
    let mainStoryboardName = "Main"
    
    var navigator: Navigator? {
        let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        let viewController = appDelegate?.window?.rootViewController as? Navigator
        return viewController
    }
    
    func push(vc: UIViewController, animated: Bool = true) {
        navigator?.pushViewController(vc, animated: animated)
    }
    
    /*
     func pushOrReuse(vc: UIViewController,
     animated: Bool = true,
     setup: ((_ vc: UIViewController, _ reuse: Bool) -> Void)?) {
     if let sameControllers = navigator?.viewControllers.filter({ type(of: $0) == type(of: vc) }),
     let reusableVC = sameControllers.last {
     setup?(reusableVC, true)
     navigator?.popToViewController(reusableVC, animated: animated)
     } else {
     setup?(vc, false)
     navigator?.pushViewController(vc, animated: animated)
     }
     }
     */
    
    func applicationDidFinishLaunching(launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        //presentRootViewController(window: window)
        
        //        if let remoteNotification = RemoteNotification(launchOptions: launchOptions) {
        //            //Routing.notifications.handleRemoteNotification(remoteNotification)
        //        }
    }
    
}
