//
//  SelectSampleTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.

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

import Kingfisher
import UIKit

struct SelectSampleCellData {
    let title: String
    let segue: String
}

class TeammatesTVC: UITableViewController {
    var teammatesData: [TeammateListEntity] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.indicator.startAnimating()
        service.server.updateTimestamp { [weak self] timestamp, error in
            self?.loadTeammates()
        }
    }
    
    private func loadTeammates() {
        let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: service.server.timestamp)
        
        let body = RequestBodyFactory.teammatesBody(key: key)
        let request = TeambrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList(let teammates) = response {
                self?.teammatesData = teammates
                self?.tableView.indicator.stopAnimating()
            }
        })
        request.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teammatesData.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < teammatesData.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "teammates cell", for: indexPath)
                as? TeammatesCell else { fatalError() }
            
            let teammate = teammatesData[indexPath.row]
            cell.nameLabel.text = teammate.name.entire
            let url = URL(string: URLBuilder().avatarURLstring(for: teammate.avatar))
            cell.avatarImageView.kf.setImage(with: url)
            cell.avatarImageView.limbColor = .white
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "test cell", for: indexPath) as? TestCell else {
            fatalError()
        }
        if !teammatesData.isEmpty && cell.roundImages.isEmpty {
            let max = teammatesData.count > 4 ? 4 : teammatesData.count
            let images = teammatesData[0..<max].flatMap { URL(string: URLBuilder().avatarURLstring(for: $0.avatar)) }
            let label: String? = teammatesData.count > 3 ? "\(teammatesData.count - 3)+" : nil
            cell.roundImages.set(images: images, label: label)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(type: .teammate, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .normal, title: "Test") { action, indexPath -> Void in
            self.isEditing = false
            log("Rate button pressed", type: .userInteraction)
        }
        action1.backgroundColor = .orange
        
        let action2 = UITableViewRowAction(style: .normal, title: "Guest") { action, indexPath -> Void in
            self.isEditing = false
            log("Share button pressed", type: .userInteraction)
        }
        action2.backgroundColor = .magenta
        return [action2, action1]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.type == .teammate {
            guard let vc = segue.destination as? TeammateVC else {
                fatalError("wrong destination for Teammate segue")
            }
            guard let indexPath = sender as? IndexPath else {
                fatalError("wrong sender for Teammate segue")
            }
            
            vc.teammate = teammatesData[indexPath.row]
        }
    }
}
