//
//  TransactionsresultTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import Kingfisher

class TransactionsresultTVC: UITableViewController {
    var storage: TransactionsStorage!
    var fetcher: BlockchainStorageFetcher!
    var teammates: [BlockchainTeammate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetcher = BlockchainStorageFetcher(storage: storage)
        let team = fetcher.firstTeam
        
        fetcher.teammates.map { self.teammates = $0 }
        
        let button =  UIButton(type: .custom)
        button.setTitle(team?.name, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
       // button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(tapTitle), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    func tapTitle() {
        performSegue(withIdentifier: "to team details", sender: fetcher.firstTeam)
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
        performSegue(withIdentifier: "to teammate details", sender: teammate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TransactionsTeammateVC, let teammate = sender as? BlockchainTeammate {
            vc.teammate = teammate
        } else if let vc = segue.destination as? TeamDetailsVC, let team = sender as? BlockchainTeam {
            vc.team = team
        }
    }

}
