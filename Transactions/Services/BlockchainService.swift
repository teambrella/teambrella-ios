//
//  BlockchainService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct OpCode: OptionSet {
    let rawValue: Int
    
    static let disband = OpCode(rawValue: 1)
    static let signatureCur = OpCode(rawValue: 2)
    static let signaturePrev = OpCode(rawValue: 3)
}

class BlockchainService {
    struct Constants {
        static let minWithdrawInputBTC: Decimal = 0.001
        static let тormalFeeBTC: Decimal = 0.0001
        static let topUtxosNum: Int = 10
        static let satoshisInBTC: Int = 100000000
    
        private let testingBlocktime: Int = 1445350680
        private let testNetServers: [String] = [ "https://test-insight.bitpay.com",
                                                 "https://testnet.blockexplorer.com"]
        private let mainNetServers: [String] = ["https://insight.bitpay.com",
                                                "https://blockexplorer.com",
                                                "https://blockchain.info"]
    }
    
    let accountService: AccountService
    
    init (accountService: AccountService) {
        self.accountService = accountService
    }
    
    struct ExplorerUtxo {
        let address: String
        let txid: String
        let vout: Int
        let ts: Int64
        let scriptPubKey: String
        let amount: Decimal
        let confirmation: Int
    }

//    func balance(for address: BlockchainAddress, completion: (Decimal?, Error?) -> Void) -> Decimal {
//        let query = "/api/addr/" + address.address + "/balance"
//        
//        let serverList!
//        if let testnet =  address.teammate?.team?.isTestnet ?
//   
//    }
}
