//
//  ThreadTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import SwiftSoup
import UIKit

class ThreadTVC: UITableViewController {
    var teammate: TeammateEntity!
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
        title = teammate.name.short
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
        
        cell.postLabel.text = TextAdapter().parsedHTML(string: post.postContent)
        cell.dateLabel.text = dateFormatter.string(from: post.dateCreated)
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
