//
//  TransactionsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftyJSON
import UIKit

class TransactionsVC: UIViewController {
    let server = TransactionsServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        server.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapInit(_ sender: Any) {
        server.initClient(privateKey: TransactionsServer.Constant.fakePrivateKey)
    }
    
    @IBAction func tapUpdates(_ sender: Any) {
        server.getUpdates(privateKey: TransactionsServer.Constant.fakePrivateKey,
                          lastUpdated: 0,
                          transactions: [],
                          signatures: [])
    }
    
}

extension TransactionsVC: TransactionsServerDelegate {
    func serverInitialized(server: TransactionsServer) {
        print("server initialized")
    }
    
    func server(server: TransactionsServer, didReceiveUpdates updates: JSON) {
        print("server received updates: \(updates)")
    }
    
    func server(server: TransactionsServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: TransactionsServer, failedWithError error: Error?) {
        print("Error: \(error)")
    }
}
