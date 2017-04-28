//
//  ThreadTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftSoup
import UIKit

class ThreadTVC: UITableViewController {
    var teammate: Teammate!
    var messages: [Post] = []
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:SS dd:MM:YYYY"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let posts = teammate.extended?.topic.posts {
            self.messages = posts.reversed()
        }
        title = teammate.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath)
            as? ThreadPostCell else { fatalError() }
        
        let post = messages[indexPath.row]
        
        cell.postLabel.text = parsed(string: post.postContent)
        cell.dateLabel.text = dateFormatter.string(from: post.dateCreated)
        // Configure the cell...
        
        return cell
    }
    
    func parsed(string: String) -> String {
        do {
            let doc: Document = try SwiftSoup.parse(string)
            return try doc.text()
        } catch Exception.Error(let type, let message) {
            print("\(type) --> " + message)
        } catch {
            print("error")
        }
        print("Falling back to original message")
        return string
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
