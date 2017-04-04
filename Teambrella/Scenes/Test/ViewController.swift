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
    @IBOutlet var console: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTimestamp {}
    }
    
    func requestTimestamp(completion: @escaping () -> Void) {
        guard server.timestamp == 0 else {
            completion()
            return
        }
        
        let request = AmbrellaRequest(type: .timestamp, success: { [weak self] response in
            if case .timestamp(let timestamp) = response {
                self?.textField.text = String(timestamp)
                self?.consoleAdd(text: String(timestamp))
                completion()
            }
        })
        request.start()
    }

    private func consoleAdd(text: String) {
        let text = console.text + text + "\n\n"
        console.text = text
    }
    
    @IBAction func tapInitClient() {
        requestTimestamp {
            
        }
    }
    
    @IBAction func tapTeammates() {
//        guard let timestamp = timestamp else { return }
        
        textField.text = "Getting teammates"
        let body = RequestBodyFactory.fakeTeammatesBody()
        let request = AmbrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList(let replyString) = response {
                self?.textField.text = "got teammates"
                self?.consoleAdd(text: replyString)
            }
        })
        request.start()
    }
    
}
