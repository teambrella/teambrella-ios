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
     let lastUpdated = storage.lastUpdated
        server.getUpdates(privateKey: TransactionsServer.Constant.fakePrivateKey,
                          lastUpdated: lastUpdated,
                          transactions: [],
                          signatures: [])
    }
    
    @IBAction func tapCosigners(_ sender: Any) {
        let request: NSFetchRequest<BlockchainCosigner> = BlockchainCosigner.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "address.addressValue", ascending: true),
                                   NSSortDescriptor(key: "keyOrderValue", ascending: true)]
        let results = try? storage.context.fetch(request)
        results?.forEach { item in
            print(item.description)
        }
    }
    @IBAction func tapGenPrivate(_ sender: Any) {
        let key = Key(base58String: TransactionsServer.Constant.fakePrivateKey, timestamp: server.timestamp)
        print("timestamp: \(key.timestamp)\nprivate key: \(key.privateKey)\npublic key: \(key.publicKey)")
        print("signature: \(key.signature)")
        let link = "https://surilla.com/me/ClientLogin?data="
        let data = "{\"Timestamp\":\"\(key.timestamp)\","
            + "\"Signature\":\"\(key.signature)\","
            + "\"PublicKey\":\"\(key.publicKey)\"}"
        print(link + data)
        print("\n\n")
        // urlQueryAllowed doesn't conform to what server is waiting for
        // use https://www.w3schools.com/tags/ref_urlencode.asp
        guard let urlSafeData = data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("Can't create string")
        }
        
        print(link + urlSafeData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TransactionsresultTVC {
            vc.storage = storage
        }
    }
    
}

extension TransactionsVC: TransactionsServerDelegate {
    func serverInitialized(server: TransactionsServer) {
        print("server initialized")
    }
    
    func server(server: TransactionsServer, didReceiveUpdates updates: JSON, updateTime: Int64) {
//        print("server received updates: \(updates)")
        storage.update(with: updates, updateTime: updateTime)
        performSegue(withIdentifier: "to transactions result", sender: nil)
        
    }
    
    func server(server: TransactionsServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: TransactionsServer, failedWithError error: Error?) {
        error.map { print("server request failed with error: \($0)") }
    }
}
