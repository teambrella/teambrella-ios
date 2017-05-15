//
//  PaymentsTVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftyJSON
import UIKit

class PaymentsTVC: UITableViewController {
    var teambrella: TeambrellaService!
    
    var resolvable: [Tx] = []
    var cosignable: [Tx] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        teambrella.delegate = self
        resolvable = teambrella.fetcher.transactionsResolvable 
        cosignable = teambrella.fetcher.transactionsCosignable ?? []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return resolvable.count
        case 1: return cosignable.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transaction cell",
                                                       for: indexPath) as? TransactionCell else {
            fatalError()
        }

        let transaction: Tx!
        switch indexPath.section {
        case 0: transaction = resolvable[indexPath.row]
        default: transaction = cosignable[indexPath.row]
        }
        
        cell.amountLabel.text = String(describing: transaction.amount)
        cell.userNameLabel.text = transaction.claimTeammate?.name ?? "None"
        cell.claimNameLabel.text = String(transaction.claimID)
        // Configure the cell...

        return cell
    }

}

extension PaymentsTVC: TeambrellaServiceDelegate {
    func teambrellaDidUpdate(service: TeambrellaService) {
        
    }
}
