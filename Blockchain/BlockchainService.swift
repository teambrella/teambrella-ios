//
//  BlockchainService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation
import SwiftyJSON

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
    
    private struct ExplorerUtxo {
        let address: String
        let txid: String
        let vout: Int
        let ts: Int64
        let scriptPubKey: String
        let amount: Decimal
        let confirmation: Int
        
        init?(json: JSON) {
            guard let address = json["address"].string,
                let txid = json["txid"].string,
                let vout = json["vout"].int,
                let ts = json["ts"].int64,
                let scriptPubKey = json["String"].string,
                let amount = json["amount"].double,
                let confirmation = json["confirmation"].int else { return nil }
            
            self.address = address
            self.txid = txid
            self.vout = vout
            self.ts = ts
            self.scriptPubKey = scriptPubKey
            self.amount = Decimal(amount)
            self.confirmation = confirmation
        }
    }
    
    private struct ExplorerTxRes {
        let txID: String
    }
    
    //private unowned let storage: BlockchainStorage
    private unowned let contentProvider: TeambrellaContentProvider
    private unowned let server: BlockchainServer
    
    init(contentProvider: TeambrellaContentProvider, server: BlockchainServer) {
        self.contentProvider = contentProvider
        self.server = server
    }
    
    func fetchBalance(address: CryptoAddress?, completion: @escaping (_ balance: Decimal) -> Void) {
        guard let address = address else {
            completion(-1)
            return
        }
        
        let query = "/api.addr/" + address.address + "/balance"
        
        let servers = server.isTestnet ? Constants.testNetServers : Constants.mainNetServers
        var isFetched = false
        var attempts = servers.count
        for serverURL in servers {
            let urlString = serverURL + query
            server.fetch(urlString: urlString, success: { result in
                attempts -= 1
                guard isFetched == false, let value = result.double else {
                    return
                }
                
                isFetched = true
                let balance = Decimal(value)
                completion(balance >= 0 ? balance : -1)
            }) {
                attempts -= 1
                if attempts <= 0 && isFetched == false {
                    completion(-1)
                }
            }
        }
    }
    
    private func fetchUtxos(address: CryptoAddress?, minAmount: Decimal, completion: @escaping (_ utxos: [ExplorerUtxo]?) -> Void) {
        guard let address = address else {
            completion([])
            return
        }
        
        let query = "/api.addr/" + address.address + "/utxo"
        
        let servers = server.isTestnet ? Constants.testNetServers : Constants.mainNetServers
        var isFetched = false
        var attempts = servers.count
        for serverURL in servers {
            let urlString = serverURL + query
            server.fetch(urlString: urlString, success: { result in
                attempts -= 1
                guard isFetched == false, let value = result.array else { return }
                
                isFetched = true
                
                completion(value.flatMap { ExplorerUtxo(json: $0) }.filter { $0.amount >= minAmount })
            }) {
                attempts -= 1
                if attempts <= 0 && isFetched == false {
                    // utox may be null when no interenet connection.
                    completion(nil)
                }
            }
        }
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
        
        let resTx = BTCTransaction()
        let txInputs = tx.inputs
        
        guard !txInputs.isEmpty else {
            print("tx has no inputs")
            return nil
        }
        
        for  txInput in txInputs {
            totalBTCAmount += txInput.ammount
            let input = BTCTransactionInput()
            resTx.inputs.append(input)
            input.previousIndex = UInt32(txInput.previousTransactionIndex)
            input.previousHash = BTCHashFromID(txInput.previousTransactionID)
        }
        
        //totalBTCAmount -= tx.fee ?? Constants.normalFeeBTC
        
        guard totalBTCAmount >= tx.amount else {
            print("totalBTCAmount \(totalBTCAmount) is less than tx amount \(tx.amount)")
            print("txInputs count: \(txInputs.count)")
            
            return nil
        }
        
        let team = tx.teammate.team
        switch tx.kind {
        case .payout?,
             .withdraw?:
            let outputs = tx.outputs
            var outputSum: Decimal = 0
            for output in outputs {
                let bitcoinAddress = btcAddress(team: team, address: output.payTo.address)
                resTx.addOutput(BTCTransactionOutput(value: btc(from: output.amount), address: bitcoinAddress))
                outputSum += output.amount
            }
            let changeAmount = totalBTCAmount - outputSum
            if changeAmount > Constants.normalFeeBTC {
                let bitcoinAddressChange = btcAddress(team: team, address: tx.teammate.addressCurrent?.address)
                resTx.addOutput(BTCTransactionOutput(value: btc(from: changeAmount), address: bitcoinAddressChange))
            }
        case .moveToNextWallet?:
            let bitcoinAddress = btcAddress(team: team, address: tx.teammate.addressNext?.address)
            resTx.addOutput(BTCTransactionOutput(value: btc(from: totalBTCAmount), address: bitcoinAddress))
        case .saveFromPreviousWallet?:
            let bitcoinAddress = btcAddress(team: team, address: tx.teammate.addressCurrent?.address)
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
        let user = contentProvider.user
        let txs = contentProvider.transactionsCosignable
        
        for tx in txs {
            guard let blockchainTx = btcTransaction(tx: tx) else {
                print("couldn't create blockchainTransaction from: \(tx.id.uuidString)")
                continue
            }
            
            guard let fromAddress = tx.fromAddress else {
                print("tx \(tx.id.uuidString) kind: \(String(describing: tx.kind)) has no valid fromAddress")
                continue
            }
            
            let redeemScript = SignHelper.redeemScript(address: fromAddress)
            let txInputs = tx.inputs
            for (idx, input) in txInputs.enumerated() {
                guard let signature = SignHelper.cosign(redeemScript: redeemScript,
                                                        key: user.key().key,
                                                        transaction: blockchainTx,
                                                        inputNum: idx) else {
                                                            fatalError()
                }
                contentProvider.addNewSignature(input: input, tx: tx, signature: signature)
            }
            tx.resolution = .signed
        }
    }
    
    // master sign
    func publishApprovedAndCosignedTxs() {
        let user = contentProvider.user
        let txs = contentProvider.transactionsApprovedAndCosigned
        
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
                    if let txSignature = contentProvider.signature(input: input.id, teammateID: cosigner.teammate.id) {
                        var vchSig = txSignature.signature
                        vchSig.append(BTCSignatureHashType.BTCSignatureHashTypeAll.rawValue)
                        ops.appendData(vchSig)
                    } else {
                        break
                    }
                }
            }
            
            for (idx, input) in txInputs.enumerated() {
                guard let signature = SignHelper.cosign(redeemScript: redeemScript,
                                                        key: user.key().key,
                                                        transaction: blockchainTx,
                                                        inputNum: idx) else {
                                                            fatalError()
                }
                contentProvider.addNewSignature(input: input, tx: tx, signature: signature)
                
                var vchSig = signature
                vchSig.append(BTCSignatureHashType.BTCSignatureHashTypeAll.rawValue)
                vchSig.append(redeemScript.data)
                ops.appendData(vchSig)
                (blockchainTx.inputs as! [BTCTransactionInput])[idx].signatureScript = BTCScript(data: vchSig)
            }
            let strTx = blockchainTx.hex!
            postTx(hexString: strTx) { success in
                self.contentProvider.transactionsChangeResolution(txs: [tx], to: .published)
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
    
    func updateData() {
        cosignApprovedTxs()
        publishApprovedAndCosignedTxs()
    }
    
//    func userCosignatures(address: BtcAddress, transaction: BTCTransaction) -> [Data] {
//        let user = storage.fetcher.user
//        let redeemScript = SignHelper.redeemScript(address: address)
//        var cosignatures: [Data] = []
//        guard let inputs = transaction.inputs as? [BTCTransactionInput] else { fatalError() }
//        
//        for (idx, input) in inputs.enumerated() {
//            guard let cosignature = SignHelper.cosign(redeemScript: redeemScript,
//                                                key: user.bitcoinPrivateKey.key,
//                                                transaction: transaction,
//                                                inputNum: idx) else { fatalError() }
//            
//            cosignatures.append(cosignature)
//        }
//        return cosignatures
//    }
}
