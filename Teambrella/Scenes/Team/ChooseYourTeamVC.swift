//
//  ChooseYourTeamVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.

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

import UIKit

protocol ChooseYourTeamControllerDelegate: class {
    func chooseTeam(controller: ChooseYourTeamVC, didSelectTeamID: Int)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "Team.ChooseYourTeamVC.header".localized
        dataSource.createModels()
        
        tableView.register(TeamCell.nib, forCellReuseIdentifier: TeamCell.cellID)
        tableView.register(SwitchUserCell.nib, forCellReuseIdentifier: SwitchUserCell.cellID)
        container.layer.cornerRadius = 4
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapCancel))
        recognizer.delegate = self
        backView.addGestureRecognizer(recognizer)
        backView.isUserInteractionEnabled = true
        
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
    
    @objc
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
        let identifier: String
        switch dataSource[indexPath] {
        case _ as SwitchUserTeamCellModel:
            identifier = SwitchUserCell.cellID
        default:
            identifier = TeamCell.cellID
        }
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}

extension ChooseYourTeamVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let model = dataSource[indexPath]
        if let cell = cell as? TeamCell, let model = model as? ChooseYourTeamCellModel {
            cell.teamIcon.showImage(string: model.teamIcon)
            cell.incomingCount.text = String(model.incomingCount)
            cell.incomingCount.isHidden = model.incomingCount == 0
            cell.teamName.text = model.teamName
            cell.itemName.text = model.itemName
            cell.coverage.text = String(model.coverage) + "%"
            cell.tick.isHidden = indexPath.row != dataSource.currentTeamIndex
        } else if let cell = cell as? SwitchUserCell, let model = model as? SwitchUserTeamCellModel {
            cell.infoLabel.text = model.name
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != dataSource.currentTeamIndex else {
            tapCancel()
            return
        }
        
        guard let team = dataSource[indexPath] as? ChooseYourTeamCellModel else {
            service.router.logout()
            tapCancel()
            return
        }
        
        service.session?.switchToTeam(id: team.teamID)
        tableView.reloadData()
        delegate?.chooseTeam(controller: self, didSelectTeamID: team.teamID)
        tapCancel()
    }
}

extension ChooseYourTeamVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
