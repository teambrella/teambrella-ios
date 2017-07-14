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
    static let storyboardName = "Team"

    @IBOutlet var backView: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var header: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    
    fileprivate var dataSource = ChooseYourTeamDataSource()
    weak var delegate: ChooseYourTeamControllerDelegate?
    
    var currentTeam = service.session.currentTeam
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "Team.ChooseYourTeamVC.header".localized
        dataSource.createFakeModels()
        tableView.register(TeamCell.nib, forCellReuseIdentifier: TeamCell.cellID)
        container.layer.cornerRadius = 4
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapCancel))
        view.addGestureRecognizer(recognizer)
        backView.alpha = 0
        self.container.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewHeight.constant = min(tableView.contentSize.height, 300)
        tableView.isScrollEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    func appear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.backView.alpha = 1
            self.container.alpha = 1
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.container.alpha = 0
            self.backView.backgroundColor = .clear
        }) { finished in
            completion()
        }
    }
    
    func tapCancel() {
        disappear {
            self.dismiss(animated: false, completion: nil)
        }
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
            cell.incomingCount.isHidden = model.incomingCount == 0
            cell.teamName.text = model.teamName
            cell.itemName.text = model.itemName
            cell.coverage.text = String(model.coverage) + "%"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? TeamCell {
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
//        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
