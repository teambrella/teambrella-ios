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
    @IBOutlet var sortView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    fileprivate var dataSource = SortDataSource()
    weak var delegate: SortTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = "Sort by".uppercased()
        dataSource.createFakeModels()
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
            cell.checker.isHidden = !model.isChecked
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(dataSource.count)
    }
}
