//
//  ViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
let server = ServerService()
    
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTimestamp()
    }
    
    func requestTimestamp() {
        let request = AmbrellaRequest(type: .timestamp, success: { [weak self] response in
            if case .timestamp(let timestamp) = response {
                self?.textField.text = String(timestamp)
            }
        })
        request.start()
    }

}
