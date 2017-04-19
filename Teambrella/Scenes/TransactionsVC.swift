//
//  TransactionsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import SwiftyJSON
import UIKit

class TransactionsVC: UIViewController {
    let server = TransactionsServer()
    let storage = TransactionsStorage()
    
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
    
    @IBAction func tapCosigners(_ sender: Any) {
        let request: NSFetchRequest<KeychainCosigner> = KeychainCosigner.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "address.addressValue", ascending: true),
                                   NSSortDescriptor(key: "keyOrderValue", ascending: true)]
        let results = try? storage.context.fetch(request)
        results?.forEach { item in
            print(item.description)
        }
    }
    
}

extension TransactionsVC: TransactionsServerDelegate {
    func serverInitialized(server: TransactionsServer) {
        print("server initialized")
    }
    
    func server(server: TransactionsServer, didReceiveUpdates updates: JSON) {
//        print("server received updates: \(updates)")
        storage.update(with: updates)
        
    }
    
    func server(server: TransactionsServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: TransactionsServer, failedWithError error: Error?) {
        error.map { print("server request failed with error: \($0)") }
    }
}
