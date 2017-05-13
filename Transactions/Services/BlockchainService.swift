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
        static let normalFeeBTC: Decimal = 0.0001
        static let topUtxosNum: Int = 10
        static let satoshisInBTC: Int = 100000000
        
        private let testingBlocktime: Int = 1445350680
        private let testNetServers: [String] = [ "https://test-insight.bitpay.com",
                                                 "https://testnet.blockexplorer.com"]
        private let mainNetServers: [String] = ["https://insight.bitpay.com",
                                                "https://blockexplorer.com",
                                                "https://blockchain.info"]
    }
    
//    let accountService: AccountService
//    
//    init (accountService: AccountService) {
//        self.accountService = accountService
//    }
    
    struct ExplorerUtxo {
        let address: String
        let txid: String
        let vout: Int
        let ts: Int64
        let scriptPubKey: String
        let amount: Decimal
        let confirmation: Int
    }
    
    func btcTransaction(tx: Tx) -> BTCTransaction? {
        var totalBTCAmount: Decimal = 0
        
        guard let address = tx.teammate?.addressCurrent else { fatalError() }
        
        var resTx = BTCTransaction()
        let inputs = tx.input as! Set<TxInput>
        var txInputs = Array(inputs).sorted { $0.id > $1.id }
        
        for (idx, txInput) in txInputs.enumerated() {
            totalBTCAmount += txInput.ammount
            let input = BTCTransactionInput()
            resTx.inputs.append(input)
            input.previousIndex = UInt32(txInput.previousTransactionIndex)
            input.previousHash = BTCHashFromID(txInput.previousTransactionID!)
        }
        
        totalBTCAmount -= tx.fee ?? Constants.normalFeeBTC
        guard totalBTCAmount >= tx.amount else { return nil }
        
        /*
        if (tx.Kind == TxKind.Payout || tx.Kind == TxKind.Withdraw)
        {
            var txOutputs = tx.Outputs.OrderBy(x => x.Id).ToList();
            var outputSum = 0M;
            for (int output = 0; output < txOutputs.Count; output++)
            {
                var txOutput = txOutputs[output];
                var bitcoinAddress = tx.Teammate.Team.Network.CreateBitcoinAddress(txOutput.PayTo.Address);
                resTx.Outputs.Add(new TxOut(new Money(txOutput.AmountBTC, MoneyUnit.BTC), bitcoinAddress));
                outputSum += txOutput.AmountBTC;
            }
            var changeAmount = totalBTCAmount - outputSum;
            if (changeAmount > NormalFeeBTC)
            {
                var bitcoinAddressChange = tx.Teammate.Team.Network.CreateBitcoinAddress(tx.Teammate.BtcAddressCurrent.Address);
                resTx.Outputs.Add(new TxOut(new Money(changeAmount, MoneyUnit.BTC), bitcoinAddressChange));
            }
        }
        else if (tx.Kind == TxKind.MoveToNextWallet)
        {
            var bitcoinAddress = tx.Teammate.Team.Network.CreateBitcoinAddress(tx.Teammate.BtcAddressNext.Address);
            resTx.Outputs.Add(new TxOut(new Money(totalBTCAmount, MoneyUnit.BTC), bitcoinAddress));
        }
        else if (tx.Kind == TxKind.SaveFromPrevWallet)
        {
            var bitcoinAddress = tx.Teammate.Team.Network.CreateBitcoinAddress(tx.Teammate.BtcAddressCurrent.Address);
            resTx.Outputs.Add(new TxOut(new Money(totalBTCAmount, MoneyUnit.BTC), bitcoinAddress));
        }
        
        return resTx;
    */
        return resTx
    }

//    func balance(for address: BlockchainAddress, completion: (Decimal?, Error?) -> Void) -> Decimal {
//        let query = "/api/addr/" + address.address + "/balance"
//        
//        let serverList!
//        if let testnet =  address.teammate?.team?.isTestnet ?
//   
//    }
}
