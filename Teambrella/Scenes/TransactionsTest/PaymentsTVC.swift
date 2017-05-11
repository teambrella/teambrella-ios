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
    var server: BlockchainServer!
    var storage: TransactionsStorage!
    lazy var fetcher: BlockchainStorageFetcher = {
        return BlockchainStorageFetcher(context: self.storage.context)
    }()
    
    var resolvable: [Tx] = []
    var cosignable: [Tx] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        server.delegate = self
        resolvable = fetcher.resolvableTransactions ?? []
        cosignable = fetcher.cosignableTransactions ?? []
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

extension PaymentsTVC: BlockchainServerDelegate {
    func serverInitialized(server: BlockchainServer) {
        print("server initialized")
    }
    
    func server(server: BlockchainServer, didReceiveUpdates updates: JSON, updateTime: Int64) {
        print("server received updates: \(updates)")
        
    }
    
    func server(server: BlockchainServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: BlockchainServer, failedWithError error: Error?) {
        error.map { print("server request failed with error: \($0)") }
    }
}
