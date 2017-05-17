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
    
    private unowned let storage: BlockchainStorage
    
    init(storage: BlockchainStorage) {
        self.storage = storage
    }
    
    /// returns Satoshis amount from BTC amount
    func btc(from decimal: Decimal) -> BTCAmount {
        return BTCAmount(decimal.double * Double(BTCCoin))
    }
    
    // getTx
    func btcTransaction(tx: Tx) -> BTCTransaction? {
        let _id = tx.id.uuidString
        print("btc transaction from tx id: \(_id)")
        var totalBTCAmount: Decimal = 0
        
        let address = tx.teammate?.addressCurrent
        
        let resTx = BTCTransaction()
        let txInputs = tx.inputs
        
        for  txInput in txInputs {
            totalBTCAmount += txInput.ammount
            let input = BTCTransactionInput()
            resTx.inputs.append(input)
            input.previousIndex = UInt32(txInput.previousTransactionIndex)
            input.previousHash = BTCHashFromID(txInput.previousTransactionID!)
        }
       
        totalBTCAmount -= tx.fee ?? Constants.normalFeeBTC
        guard totalBTCAmount >= tx.amount else {
            print("totalBTCAmount \(totalBTCAmount) is less than tx amount \(tx.amount)")
            print("txInputs count: \(txInputs.count)")
            
            return nil
        }
        
        let team = tx.teammate!.team!
        switch tx.kind {
        case .payout?,
             .withdraw?:
            let outputs = tx.outputs
            var outputSum: Decimal = 0
            for output in outputs {
                let bitcoinAddress = btcAddress(team: team, address: output.payTo?.address)
                resTx.addOutput(BTCTransactionOutput(value: btc(from: output.amount), address: bitcoinAddress))
                outputSum += output.amount
            }
            let changeAmount = totalBTCAmount - outputSum
            if changeAmount > Constants.normalFeeBTC {
                let bitcoinAddressChange = btcAddress(team: team, address: tx.teammate?.addressCurrent?.address)
                resTx.addOutput(BTCTransactionOutput(value: btc(from: changeAmount), address: bitcoinAddressChange))
            }
        case .moveToNextWallet?:
            let bitcoinAddress = btcAddress(team: team, address: tx.teammate?.addressNext?.address)
            resTx.addOutput(BTCTransactionOutput(value: btc(from: totalBTCAmount), address: bitcoinAddress))
        case .saveFromPreviousWallet?:
            let bitcoinAddress = btcAddress(team: team, address: tx.teammate?.addressCurrent?.address)
            resTx.addOutput(BTCTransactionOutput(value: btc(from: totalBTCAmount), address: bitcoinAddress))
        default: break
        }
        return resTx
    }
    
    func btcAddress(team: Team, address: String?) -> BTCAddress? {
        guard let address = address else { return nil}
        return team.isTestnet
            ? BTCPublicKeyAddressTestnet(string: address)
            : BTCPublicKeyAddress(string: address)
    }
    
    func cosignApprovedTxs() {
        let user = storage.fetcher.user
        let txs = storage.fetcher.transactionsResolvable
        
        for tx in txs {
            guard let blockchainTx = btcTransaction(tx: tx) else {
                print("couldn't create blockchainTransaction from: \(tx)")
                continue
            }
            
            guard let fromAddress = tx.fromAddress else {
                print("tx has no valid fromAddress")
                continue
            }
            
            let redeemScript = SignHelper.redeemScript(address: fromAddress)
            let txInputs = tx.inputs
            for (idx, input) in txInputs.enumerated() {
                let signature = SignHelper.cosign(redeemScript: redeemScript,
                                                  key: user.bitcoinPrivateKey.key,
                                                  transaction: blockchainTx,
                                                  inputNum: idx)
                storage.fetcher.addNewSignature(input: input, tx: tx, signature: signature)
            }
            tx.resolution = .signed
            storage.fetcher.save()
        }
    }
    
    func publishApprovedAndCosignedTxs() {
        let user = storage.fetcher.user
        let txs = storage.fetcher.transactionsApprovedAndCosigned
        
        for tx in txs {
            guard let blockchainTx = btcTransaction(tx: tx) else { fatalError() }
            guard let fromAddress = tx.fromAddress else {
                print("can't publish tx as it has no valid fromAddress")
                continue
            }
            
            let redeemScript = SignHelper.redeemScript(address: fromAddress)
            let txInputs = tx.inputs
            
            guard let ops = BTCScript() else { fatalError() }
            
            ops.append(.OP_0)
            for cosigner in fromAddress.cosigners {
                for input in txInputs {
                    if let txSignature = storage.fetcher.signature(input: input.id, teammateID: cosigner.teammate!.id) {
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
                storage.fetcher.addNewSignature(input: input, tx: tx, signature: signature)
                
                var vchSig = signature
                vchSig.append(BTCSignatureHashType.BTCSignatureHashTypeAll.rawValue)
                vchSig.append(redeemScript.data)
                ops.appendData(vchSig)
                (blockchainTx.inputs as! [BTCTransactionInput])[idx].signatureScript = BTCScript(data: vchSig)
            }
            let strTx = blockchainTx.hex!
            postTx(hexString: strTx) { success in
                self.storage.fetcher.transactionsChangeResolution(txs: [tx], to: .published)
            }
        }
        
    }
    
    private func postTx(hexString: String, completion: @escaping (_ success: Bool) -> Void) {
        var replies = 0
        var replied = false
        let servers = storage.server.isTestnet ? Constants.testNetServers : Constants.mainNetServers
        for url in servers {
            storage.server.postTxExplorer(tx: hexString, urlString: url, success: { txID in
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
    
    func updateData() {
        cosignApprovedTxs()
        publishApprovedAndCosignedTxs()
        storage.save()
    }
    
}
