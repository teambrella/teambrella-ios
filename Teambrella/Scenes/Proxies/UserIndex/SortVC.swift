//
//  UserIndexSortVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 05.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol SortControllerDelegate: class {
    func sort(controller: SortVC, didSelect type: SortVC.SortType)
}

class SortVC: UIViewController, Routable {
    enum SortType: Int {
        case none = -1
        case ratingHiLo = 0
        case ratingLoHi = 1
        case alphabeticalAtoZ = 2
        case alphabeticalZtoA = 3
    }
    
    static let storyboardName = "Proxies"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var sortView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    fileprivate var dataSource = SortDataSource()
    weak var delegate: SortControllerDelegate?
    
    var type: SortType = .none
    
    @IBAction func tapClose(_ sender: Any) {
        disappear {
            self.dismiss(animated: false, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = "Sort by".uppercased()
        dataSource.createFakeModels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    func appear() {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        self.bottomConstraint.constant = -self.sortView.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.backView.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }) { finished in
            completion()
        }
    }
    
}

extension SortVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath)
    }
}

extension SortVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SortCell {
            let model = dataSource[indexPath]
            
            cell.topLabel.text = model.topText
            cell.bottomLabel.text = model.bottomText
            cell.checker.isHidden = indexPath.row != type.rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(dataSource.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SortCell {
            if  type.rawValue != indexPath.row {
                if type != .none,
                    let otherCell = tableView.cellForRow(at: IndexPath(row: type.rawValue, section: 0)) as? SortCell {
                    otherCell.checker.isHidden = true
                }
                cell.checker.isHidden = false
                type = SortType(rawValue: indexPath.row) ?? .none
                delegate?.sort(controller: self, didSelect: type)
            } else {
                cell.checker.isHidden = true
                type = .none
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
