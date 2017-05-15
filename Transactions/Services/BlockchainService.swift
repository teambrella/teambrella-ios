//
//  BlockchainService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class BlockchainService {
    fileprivate struct OpCode: OptionSet {
        let rawValue: Int
        
        static let disband = OpCode(rawValue: 0x01)
        static let signatureCur = OpCode(rawValue: 0x02)
        static let signaturePrev = OpCode(rawValue: 0x03)
    }
    
    struct Constants {
        static let minWithdrawInputBTC: Decimal = 0.001
        static let normalFeeBTC: Decimal = 0.0001
        static let topUtxosNum: Int = 10
        static let satoshisInBTC: Int = 100000000
        
        fileprivate static let testingBlocktime: Int = 1445350680
        fileprivate static let testNetServers: [String] = [ "https://test-insight.bitpay.com",
                                                            "https://testnet.blockexplorer.com"]
        fileprivate static let mainNetServers: [String] = ["https://insight.bitpay.com",
                                                           "https://blockexplorer.com",
                                                           "https://blockchain.info"]
    }
    
    //    let accountService: AccountService
    //
    //    init (accountService: AccountService) {
    //        self.accountService = accountService
    //    }
    
    private struct ExplorerUtxo {
        let address: String
        let txid: String
        let vout: Int
        let ts: Int64
        let scriptPubKey: String
        let amount: Decimal
        let confirmation: Int
    }
    
    private unowned let fetcher: BlockchainStorageFetcher
    private unowned let server: BlockchainServer
    
    init(fetcher: BlockchainStorageFetcher, server: BlockchainServer) {
        self.fetcher = fetcher
        self.server = server
    }
    
    func updateData() {
        cosignApprovedTxs()
        publishApprovedAndCosignedTxs()
        fetcher.storage.save()
    }
    
    // getTx
    func btcTransaction(tx: Tx) -> BTCTransaction? {
        var totalBTCAmount: Decimal = 0
        
        let address = tx.teammate?.addressCurrent
        
        var resTx = BTCTransaction()
        var txInputs = tx.inputs
        
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
    
    func cosignApprovedTxs() {
        let user = fetcher.user
        let txs = fetcher.transactionsResolvable 
        
        for tx in txs {
            guard let blockchainTx = btcTransaction(tx: tx) else {
                print("couldn't create blockchainTransaction from: \(tx)")
                continue
            }
            
            let redeemScript = SignHelper.redeemScript(address: tx.fromAddress)
            let txInputs = tx.inputs
            for (idx, input) in txInputs.enumerated() {
                let signature = SignHelper.cosign(redeemScript: redeemScript,
                                                  key: user.bitcoinPrivateKey.key,
                                                  transaction: blockchainTx,
                                                  inputNum: idx)
                fetcher.addNewSignature(input: input, tx: tx, signature: signature)
            }
            tx.resolution = .signed
            fetcher.storage.save()
        }
    }
    
    func publishApprovedAndCosignedTxs() {
        let user = fetcher.user
        let txs = fetcher.transactionsApprovedAndCosigned
        
        for tx in txs {
            guard let blockchainTx = btcTransaction(tx: tx) else { fatalError() }
            
            let redeemScript = SignHelper.redeemScript(address: tx.fromAddress)
            let txInputs = tx.inputs
            
            guard let ops = BTCScript() else { fatalError() }
            
            ops.append(.OP_0)
            for cosigner in tx.fromAddress.cosigners {
                for input in txInputs {
                    if let txSignature = fetcher.signature(input: input.id, teammateID: cosigner.teammate!.id) {
                        var vchSig = txSignature.signature
                        vchSig.append(BTCSignatureHashType.BTCSignatureHashTypeAll.rawValue)
                        ops.appendData(vchSig)
                    } else {
                        break
                    }
                }
            }
            
            for (idx, input) in txInputs.enumerated() {
                let signature = SignHelper.cosign(redeemScript: redeemScript,
                                                  key: user.bitcoinPrivateKey.key,
                                                  transaction: blockchainTx,
                                                  inputNum: idx)
                fetcher.addNewSignature(input: input, tx: tx, signature: signature)
                
                var vchSig = signature
                vchSig.append(BTCSignatureHashType.BTCSignatureHashTypeAll.rawValue)
                vchSig.append(redeemScript.data)
                ops.appendData(vchSig)
                (blockchainTx.inputs as! [BTCTransactionInput])[idx].signatureScript = BTCScript(data: vchSig)
            }
            let strTx = blockchainTx.hex!
            postTx(hexString: strTx) { success in
                self.fetcher.transactionsChangeResolution(txs: [tx], to: .published)
            }
        }
        
    }
    
    private func postTx(hexString: String, completion: @escaping (_ success: Bool) -> Void) {
        var replies = 0
        var replied = false
        let servers = server.isTestnet ? Constants.testNetServers : Constants.mainNetServers
        for url in servers {
            server.postTxExplorer(tx: hexString, urlString: url, success: { txID in
                if replied == false {
                    replied = true
                    completion(true)
                }
            }, failure: {
                if !replied && replies == servers.count - 1 {
                    completion(false)
                }
                replies += 1
            })
        }
    }
    
}
