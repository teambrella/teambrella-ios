//
//  SelectSampleTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

struct SelectSampleCellData {
    let title: String
    let segue: String
}

class SelectSampleTVC: UITableViewController {
    var teammatesData: [Teammate] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTeammates()
    }
    
    private func loadTeammates() {
        guard let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                            timestamp: service.server.timestamp) else {
            return
        }
        
        let body = RequestBodyFactory.teammatesBody(key: key)
        let request = AmbrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
            if case .teammatesList(let teammates) = response {
              self?.teammatesData = teammates
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
        return teammatesData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "teammates cell", for: indexPath)
            as? TeammatesCell else {
            fatalError("Wrong cell type")
        }
        let teammate = teammatesData[indexPath.row]
        cell.nameLabel.text = teammate.name
        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
        cell.avatarImageView.kf.setImage(with: url)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "to teammate", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to teammate" {
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
