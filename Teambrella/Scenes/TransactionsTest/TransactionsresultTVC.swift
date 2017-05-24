//
//  TransactionsresultTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

class TransactionsresultTVC: UITableViewController {
    var teambrella: TeambrellaService!
    var teammates: [Teammate] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let team = teambrella.fetcher.firstTeam
        
        teammates = teambrella.fetcher.teammates
        
        let button =  UIButton(type: .custom)
        button.setTitle(team?.name, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
       // button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(tapTitle), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    func tapTitle() {
        performSegue(type: .teamDetails, sender: teambrella.fetcher.firstTeam)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teammates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse identifier", for: indexPath)
        let teammate = teammates[indexPath.row]
        
        cell.textLabel?.text = teammate.name
        cell.detailTextLabel?.text = "id: \(teammate.id)"
//        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
//        cell.imageView?.kf.setImage(with: url)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let teammate = teammates[indexPath.row]
        performSegue(type: .teamDetails, sender: teammate.team)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TransactionsTeammateVC, let teammate = sender as? Teammate {
            vc.teammate = teammate
            vc.teambrella = teambrella
        } else if let vc = segue.destination as? TeamDetailsVC, let team = sender as? Team {
            vc.team = team
        }
    }

}
