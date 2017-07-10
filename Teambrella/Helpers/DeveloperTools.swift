//
//  DeveloperTools.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct DeveloperTools {
    static func notSupportedAlert(in controller: UIViewController,
                                  title: String = "Not supported yet",
                                  message: String = "This feature is not supported in the current build."
        + " Please come back later") {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okay)
        controller.present(alert, animated: true, completion: nil)
    }
    
}
