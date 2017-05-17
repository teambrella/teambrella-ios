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

    func tapSign(sender: UIButton) {
        let cells = tableView.visibleCells.flatMap { $0 as? TransactionCell }.filter { $0.signButton == sender }
        if let cell = cells.first, let indexPath = tableView.indexPath(for: cell) {
            let transaction = tx(indexPath: indexPath)
            print("Tapped \(transaction.id)")
        }
    }
    
    func tx(indexPath: IndexPath) -> Tx {
        switch indexPath.section {
        case 0: return resolvable[indexPath.row]
        default: return cosignable[indexPath.row]
        }
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

        let transaction = tx(indexPath: indexPath)
        
        cell.amountLabel.text = String(describing: transaction.amount)
        cell.userNameLabel.text = transaction.claimTeammate?.name ?? "None"
        cell.claimNameLabel.text = String(transaction.claimID)
        cell.statusLabel.text = transaction.resolution.string
        let title = transaction.resolution == .received
            ? "Approve"
            : transaction.state == TransactionState.selectedForCosigning ? "Cosign" :  transaction.state?.string
        cell.signButton.setTitle(title, for: .normal)
        cell.signButton.removeTarget(self, action: #selector(tapSign), for: .touchUpInside)
        cell.signButton.addTarget(self, action: #selector(tapSign), for: .touchUpInside)
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Resolvable"
        case 1: return "Cosignable"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}

extension PaymentsTVC: TeambrellaServiceDelegate {
    func teambrellaDidUpdate(service: TeambrellaService) {
        
    }
}
