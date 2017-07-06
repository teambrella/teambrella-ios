//
//  UserIndexSortVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 05.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol SortTableDelegate: class {
    func sortTable(controller: SortVC, didSelect row: Int)
}

class SortVC: UIViewController, Routable {
    static let storyboardName = "Proxies"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var sortView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    fileprivate var dataSource = SortDataSource()
    weak var delegate: SortTableDelegate?
    var rowIndex: Int = -1
    
    deinit {
        print("I am now officially dead")
    }
    
    @IBAction func tapClose(_ sender: Any) {
        disappear {
            self.view.removeFromSuperview()
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
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 15, options: [], animations: {
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
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
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(dataSource.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SortCell {
            if  rowIndex != indexPath.row {
                if rowIndex >= 0,
                    let otherCell = tableView.cellForRow(at: IndexPath(row: rowIndex, section: 0)) as? SortCell {
                    otherCell.checker.isHidden = true
                }
                cell.checker.isHidden = false
                rowIndex = indexPath.row
            } else {
                cell.checker.isHidden = true
                rowIndex = -1
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
