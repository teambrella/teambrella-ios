//
//  Navigator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class Navigator: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.router.navigator = self
        
        delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension Navigator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let hide = viewController is UITabBarController
        setNavigationBarHidden(hide, animated: true)
    }
}
