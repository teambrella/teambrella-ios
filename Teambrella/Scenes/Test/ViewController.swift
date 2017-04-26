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
    
    var teammates: [Teammate] = []
    
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
            guard let me = self else { return }
            
            if case .timestamp = response {
                let stampString = String(me.server.timestamp)
                me.textField.text = stampString
                me.consoleAdd(text: stampString)
                completion()
            }
        })
        request.start()
    }

    private func consoleAdd(text: String) {
        let text = text + "\n" + console.text
        console.text = text
    }
    
    @IBAction func tapTeammates() {
        consoleAdd(text: "Test.console.getting_teammates".localized)
        let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: server.timestamp)
        
        let body = RequestBodyFactory.teammatesBody(key: key)
        let request = AmbrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList(let teammates) = response {
                self?.consoleAdd(text: "Test.console.got_teammates".localized(teammates.count))
                teammates.forEach { self?.consoleAdd(text: $0.description) }
                self?.teammates = teammates
            }
        })
        request.start()
    }
    
    @IBAction func tapTeammate() {
        guard teammates.isEmpty == false else { return }
        
        let teammate = teammates[Random.range(to: teammates.count)]
        self.consoleAdd(text: "Getting teammate \(teammate.name)")
        let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: server.timestamp)
        let body = RequestBodyFactory.teammateBody(key: key, id: teammate.id)
        let request = AmbrellaRequest(type: .teammate, body: body, success: { [weak self] response in
            if case .teammate(let teammate) = response {
                self?.consoleAdd(text: teammate.description)
            }
        })
        request.start()
    }
    
    @IBAction func tapNewPost() {
        let postText = textField.text ?? "new post"
        consoleAdd(text: "Test.console.posting".localized)
        let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: server.timestamp)
        let body = RequestBodyFactory.newPostBody(key: key,
                                                  topicID: "00000000-0000-0000-0000-00000000000a",
                                                  text: postText)
        let request = AmbrellaRequest(type: .newPost, body: body, success: { [weak self] response in
            if case .newPost(let post) = response {
                self?.consoleAdd(text: post.description)
            }
        })
        request.start()
    }
    
}
