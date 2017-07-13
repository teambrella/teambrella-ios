//
//  ChooseYourTeamVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol ChooseYourTeamControllerDelegate: class {
}

class ChooseYourTeamVC: UIViewController, Routable {
    @IBOutlet var backView: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var header: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    
    fileprivate var dataSource = ChooseYourTeamDataSource()
    weak var delegate: ChooseYourTeamControllerDelegate?
    
    var currentTeam = service.session.currentTeam
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "Team.ChooseYourTeamVC.header".localized
        dataSource.createModels()
        //contH = tableView.countOfCells + 65
    }
    
}

extension ChooseYourTeamVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
    }
}

extension ChooseYourTeamVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TeamCell {
            let model = dataSource[indexPath]
            cell.teamIcon.image = model.teamIcon
            cell.incomingCount.text = String(model.incomingCount)
            cell.incomingCount.isHidden = !(model.incomingCount > 0)
            cell.teamName.text = model.teamName
            cell.itemName.text = model.itemName
            cell.coverage.text = String(model.coverage) + "%"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TeamCell {
//            if  current.rawValue != indexPath.row {
//                if type != .none,
//                    let otherCell = tableView.cellForRow(at: IndexPath(row: type.rawValue, section: 0)) as? SortCell {
//                    otherCell.checker.isHidden = true
//                }
//                cell.tick.isHidden = false
//                //type = SortType(rawValue: indexPath.row) ?? .none
//                delegate?.sort(controller: self, didSelect: type)
//            } else {
//                cell.tick.isHidden = true
//                //type = .none
//            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
