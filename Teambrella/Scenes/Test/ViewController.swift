//
//  ViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
let server = service.server
    
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
        textField.text = "Getting teammates"
        guard let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: server.timestamp) else {
            return
        }
        
        let body = RequestBodyFactory.teammatesBody(key: key)
        let request = AmbrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList(let teammates) = response {
                self?.textField.text = "got teammates"
                teammates.forEach { self?.consoleAdd(text: $0.description) }
            }
        })
        request.start()
    }
    
    @IBAction func tapTeammate() {
        textField.text = "Getting teammate #11"
        guard let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: server.timestamp) else {
            return
        }
        
        let body = RequestBodyFactory.teammateBody(key: key, id: "00000000-0000-0000-0000-000000000005")
        let request = AmbrellaRequest(type: .teammate, body: body, success: { [weak self] response in
            if case .teammatesList(let teammate) = response {
                self?.textField.text = teammate.description
            }
        })
        request.start()
    }
    
}
