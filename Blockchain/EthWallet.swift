//
/* Copyright(C) 2017 Teambrella, Inc.
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

import ExtensionsPack
import Foundation
import Geth

class EthWallet {
    struct Constant {
        static let contractFile                 = "Contract"
        static let methodIDteamID               = "8d475461"
        static let methodIDcosigners            = "22c5ec0f"
        static let methodIDtransfer             = "91f34dbd"
        static let methodIDchangeAllCosigners   = "a0175b96"
        static let txPrefix                     = "5452"
        static let nsPrefix                     = "4E53"

        static let minGasWalletBalance: Decimal = 0.0075
        static let maxGasWalletBalance: Decimal = 0.01

        static let gasLimitBase: Int            = 100_000
        static let gasLimitForMoveTx: Int       = 200_000
        static let gasLimitForDepositTx: Int    = 50_000

        static let gasStash: Int                = 30_000

        static let gasPriceDefault: Int         = 100_000_001
        static let gasPriceMax: Int             = 50_000_000_001
        static let claimGasPriceDefault: Int    = 1_000_000_001
        static let claimGasPriceMax: Int        = 10_000_000_001
        static let contractGasPriceDefault: Int = 100_000_001
        static let contractGasPriceMax: Int     = 20_000_000_002
    }

    enum EthWalletError: Error {
        case multisigHasNoCosigners(Int)
        case contractDoesNotExist
        case multisigHasNoCreationTx(Int)
        case noMultisigs
        case allGasUsed
        case unexpectedTxInputsCount(count: Int, txID: String)
        case transactionHasNoTeammate
        case invalidCosigner(txID: String)
        case argumentsMismatch(args: [Any])
        case noFromMultisig
        case noToMultisig
        case transactionHasNoKind
    }
    
    let processor: EthereumProcessor
    let isTestNet: Bool
    
    lazy var blockchain = { EtherNode(isTestNet: self.isTestNet) }()
    
    // 0.1 Gwei is enough since October 16, 2017 (1 Gwei = 10^9 wei)
    //var gasPrice: Int { return isTestNet ? 11000000001 : 100000001 }
    //var contractGasPrice: Int { return isTestNet ? 11000000001 : 100000001 }
    var gasPrice: Int = -1
    var contractGasPrice: Int = -1
    
    
    var contract: String? {
        guard let fileURL = Bundle.main.path(forResource: Constant.contractFile, ofType: "txt") else { return nil }
        
        var string = try? String(contentsOfFile: fileURL, encoding: String.Encoding.utf8)
        if let index = string?.index(of: "\n") {
            string?.remove(at: index)
        }
        return string
    }
    
    init(isTestNet: Bool, processor: EthereumProcessor) {
        self.isTestNet = isTestNet
        self.processor = processor
    }
    
    func createOneWallet(myNonce: Int,
                         multisig: Multisig,
                         gaslLimit: Int,
                         gasPrice: Int,
                         completion: @escaping (String) -> Void,
                         failure: @escaping (Error?) -> Void) {
        let cosigners = multisig.cosigners
        guard !cosigners.isEmpty else {
            log("Multisig address id: \(multisig.id) has no cosigners", type: [.error, .cryptoDetails])
            failure(EthWalletError.multisigHasNoCosigners(multisig.id))
            return
        }
        //        guard let creationTx = multisig.creationTx else {
        //            failure(EthWalletError.multisigHasNoCreationTx(multisig.id))
        //            return
        //        }
        
        let addresses = cosigners.compactMap { $0.teammate?.address }
        guard let contract = contract else {
            failure(EthWalletError.contractDoesNotExist)
            return
        }
        
        log("Creating one Wallet", type: .cryptoDetails)
        do {
            var cryptoTx = try processor.contractTx(nonce: myNonce,
                                                    gasLimit: gaslLimit,
                                                    gasPrice: gasPrice,
                                                    byteCode: contract,
                                                    arguments: [addresses, multisig.teamID])
            cryptoTx = try processor.signTx(unsignedTx: cryptoTx, isTestNet: isTestNet)
            log("CryptoTx created with teamID: \(multisig.teamID), tx: \(cryptoTx)", type: .crypto)
            publish(cryptoTx: cryptoTx, completion: completion, failure: failure)
        } catch let AbiArguments.AbiArgumentsError.unEncodableArgument(wrongArgument) {
            log("AbiArguments failed to accept the wrong argument: \(wrongArgument)", type: [.error, .cryptoDetails])
        } catch {
            failure(error)
        }
    }
    
    func publish(cryptoTx: GethTransaction,
                 completion: @escaping (String) -> Void,
                 failure: @escaping (Error?) -> Void) {
        do {
            let rlp = try cryptoTx.encodeRLP()
            let hex = "0x" + Hex().hexStringFrom(data: rlp)
            blockchain.pushTx(hex: hex, success: { string in
                completion(string)
            }, failure: { error in
                failure(error)
            })
        } catch {
            failure(error)
        }
    }
    
    func checkMyNonce(success: @escaping (Int) -> Void, failure: @escaping (Error?) -> Void) {
        guard let address = processor.ethAddressString else { return }
        
        blockchain.checkNonce(addressHex: address, success: { nonce in
            log("Nonce: \(nonce)", type: .crypto)
            success(nonce)
        }) { error in
            failure(error)
        }
    }
    
    /**
     * Verfifies if a given contract creation TX has been mined in the blockchain.
     *
     * - Parameter gasLimit: original gas limit, that has been set to the original creation TX.
     *  When a TX consumes all the gas up to the limit, that indicates an error.
     *  - Parameter multisig: the given multisig object with original TX hash to check.
     * - returns: original multisig object with updated address (when verified successfully), updated error status
     * (if any), or new unconfirmed tx if original TX is outdated.
     */
    func validateCreationTx(multisig: Multisig,
                            gasLimit: Int,
                            success: @escaping (String) -> Void,
                            notmined: @escaping (Int) -> Void,
                            failure: @escaping (Error?) -> Void) {
        guard let creationTx = multisig.creationTx else {
            failure(EthWalletError.multisigHasNoCreationTx(multisig.id))
            return
        }
        
        blockchain.checkTx(creationTx: creationTx, success: { txReceipt in
            if !txReceipt.blockNumber.isEmpty {
                let gasUsed = Int(hexString: txReceipt.gasUsed)
                let isAllGasUsed = gasUsed == gasLimit
                if !isAllGasUsed {
                    success(txReceipt.contractAddress)
                } else {
                    failure(EthWalletError.allGasUsed)
                }
            } else {
                notmined(gasLimit)
            }
        }, failure: { error in
            failure(error)
        })
    }

    func refreshGasPrice(completion: @escaping (Int) -> Void) {
        let gasStation = GasStation()
        gasStation.gasPrice { [weak self] price, error in
            guard let `self` = self else { return }

            if let error = error {
                log("refresh gas error: \(error)", type: [.error, .crypto])
            }

            switch price {
            case ..<0:
                log("Failed to get the gas price from a server. A default gas price will be used.",
                    type: [.error, .crypto])
                self.gasPrice = Constant.gasPriceDefault
            case Constant.gasPriceMax...:
                log("The server is kidding with us about the gas price: \(price)", type: [.error, .crypto])
                self.gasPrice = Constant.gasPriceMax
            default:
                self.gasPrice = price
            }
            completion(self.gasPrice)
        }
    }

    func refreshClaimGasPrice(completion: @escaping (Int) -> Void) {
        let gasStation = GasStation()
        gasStation.gasPrice { [weak self] price, error in
            guard let `self` = self else { return }

            if let error = error {
                log("refresh gas error: \(error)", type: [.error, .crypto])
            }

            switch price {
            case ..<0:
                log("Failed to get the gas price from a server. A default gas price will be used.",
                    type: [.error, .crypto])
                self.gasPrice = Constant.claimGasPriceDefault
            case Constant.claimGasPriceMax...:
                log("""
                    With the current version gas price for a clime is limited. This high price will be supported later \
                    (when off-chain payments are implemented) : \(price)
                    """, type: [.error, .crypto])
                self.gasPrice = Constant.claimGasPriceMax
            default:
                self.gasPrice = price
            }
            completion(self.gasPrice)
        }
    }

    func refreshContractCreationGasPrice(completion: @escaping (Int) -> Void) {
        let gasStation = GasStation()
        gasStation.contractCreationGasPrice { [weak self] price, error in
            guard let `self` = self else { return }

            if let error = error {
                log("refresh gas error: \(error)", type: [.error, .crypto])
            }

            switch price {
            case ..<0:
                log("Failed to get the gas price from a server. A default gas price will be used.",
                    type: [.error, .crypto])
                self.contractGasPrice = Constant.contractGasPriceDefault
            case Constant.contractGasPriceMax...:
                log("The server is kidding with us about the contract gas price: \(price)", type: [.error, .crypto])
                self.contractGasPrice = Constant.contractGasPriceMax
            default:
                self.contractGasPrice = price
            }
            completion(self.contractGasPrice)
        }
    }

    func deposit(multisig: Multisig, completion: @escaping (Bool) -> Void) {
        guard let address = processor.ethAddressString else { return }
        
        blockchain.checkBalance(address: address, success: { gasWalletAmount in
            log("Multisig balance is \(gasWalletAmount)", type: .crypto)
            if gasWalletAmount > Constant.maxGasWalletBalance {
                self.refreshGasPrice(completion: { gasPrice in
                    self.blockchain.checkNonce(addressHex: address, success: { nonce in
                        let value = gasWalletAmount - Constant.minGasWalletBalance
                        do {
                            var tx = try self.processor.depositTx(nonce: nonce,
                                                                  gasLimit: Constant.gasLimitForDepositTx,
                                                                  toAddress: multisig.address!,
                                                                  gasPrice: gasPrice,
                                                                  value: value)
                            try tx = self.processor.signTx(unsignedTx: tx, isTestNet: self.isTestNet)
                            self.publish(cryptoTx: tx, completion: { txHash in
                                log("Deposit tx published: \(txHash)", type: .crypto)
                                completion(true)
                            }, failure: { error in
                                log("Publish Tx failed with \(String(describing: error))", type: [.error, .crypto])
                                completion(false)
                            })
                        } catch {
                            log("Deposit Tx creation failed with \(String(describing: error))", type: [.error, .crypto])
                            completion(false)
                        }
                    }, failure: { error in
                        log("Check nonce failed with \(String(describing: error))", type: [.error, .crypto])
                        completion(false)
                    })
                })
            } else {
                log("Can't deposit contract: \(gasWalletAmount), needed: \(Constant.maxGasWalletBalance)",
                    type: .cryptoDetails)
                completion(false)
            }
        }, failure: { error in
            log("Check balance failed with \(String(describing: error))", type: [.error, .crypto])
            completion(false)
        })
    }

    func cosign(transaction: Tx, payOrMoveFrom: TxInput) throws -> Data {
        guard let kind = transaction.kind else {
            throw EthWalletError.transactionHasNoKind
        }

        switch kind {
        case .moveToNextWallet:
            return try cosignMove(transaction: transaction, moveFrom: payOrMoveFrom)
        default:
            return try cosignPay(transaction: transaction, payFrom: payOrMoveFrom)
        }
    }

    func cosignPay(transaction: Tx, payFrom: TxInput) throws -> Data {
        let opNum = payFrom.previousTransactionIndex + 1
        log("Cosign pay with opNum: \(opNum)", type: .cryptoDetails)
        guard let sourceMultisig = transaction.fromMultisig else {
            log("There is no from Multisig", type: [.error, .cryptoDetails])
            throw EthWalletError.noFromMultisig
        }

        let teamID = sourceMultisig.teamID
        let payToAddresses = toAddresses(destinations: transaction.outputs)
        log("pay to addresses: \(payToAddresses)", type: .cryptoDetails)
        let payToValues = toValues(destinations: transaction.outputs)
        log("pay to values: \(payToValues)", type: .cryptoDetails)
        let h = try hashForPaySignature(teamID: teamID, opNum: opNum, addresses: payToAddresses, values: payToValues)
        log("Hash created for Tx transfer(s): \(h.hexString)", type: .crypto)
        let sig = try processor.signHashAndCalculateV(hash256: h)
        log("Hash signed. \(sig)", type: .cryptoDetails)
        return sig
    }

    func cosignMove(transaction: Tx, moveFrom: TxInput) throws -> Data {
         let opNum = moveFrom.previousTransactionIndex + 1
        guard let sourceMultisig = transaction.fromMultisig else {
            log("There is no from Multisig", type: [.error, .cryptoDetails])
            throw EthWalletError.noFromMultisig
        }
        guard let toMultisig = transaction.toMultisig else {
            log("There is no to Multisig", type: [.error, .cryptoDetails])
            throw EthWalletError.noToMultisig
        }

        let teamID = sourceMultisig.teamID
        let nextCosignerAddresses = toCosignerAddresses(nextMultisig: toMultisig)
        let hash = try hashForMoveSignature(teamID: teamID, opNum: opNum, addresses: nextCosignerAddresses)
        log("Hash created for Tx transfer(s): \(hash.hexString)", type: .crypto)
        let sig = try processor.signHashAndCalculateV(hash256: hash)
         log("Hash signed. \(sig)", type: .cryptoDetails)
        return sig
    }

    func publish(tx: Tx, completion: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        guard let kind = tx.kind else {
            failure(nil)
            return
        }

        switch kind {
        case .moveToNextWallet:
            publishMove(tx: tx, completion: completion, failure: failure)
        default:
            publishPay(tx: tx, completion: completion, failure: failure)
        }
    }

    private func toAddresses(destinations: [TxOutput]) -> [String] {
        let destinationAddresses: [String] = destinations.compactMap { output in output.saneAddress()?.string }
        return destinationAddresses
    }

    private func toCosignerAddresses(nextMultisig: Multisig) -> [String] {
        let cosigners = nextMultisig.cosigners
        return cosigners.compactMap { cosigner in cosigner.address?.string }

    }

    private func toValues(destinations: [TxOutput]) -> [String] {
        let destinationValues: [String] = destinations.compactMap { output in
            guard let amountValue = output.amountValue else { return nil }

            return AbiArguments.parseDecimalAmount(decimal: amountValue)
        }
        return destinationValues
    }

    private func hashForPaySignature(teamID: Int, opNum: Int, addresses: [String], values: [String]) throws -> Data {
        let hex = Hex()
        let a0 = Constant.txPrefix // prefix, that is used in the contract to indicate a signature for transfer tx
        let a1 = String(format: "%064x", teamID)
        let a2 = String(format: "%064x", opNum)
        let a3: [String] = addresses.map { address in hex.truncatePrefix(string: address) }
        let a4: [String] = values.map { value in hex.truncatePrefix(string: value) }
        log("Preparing hash for pay signature\na0 (prefix):\t\(a0),\na1 (teamID):\t\(a1)\na2 (opNum):\t\t\(a2)\n" +
            "a3 (addresses):\t\(a3)\na4 (values):\t\(a4)", type: .cryptoDetails)
        let data = try hex.data(from: a0, a1, a2, a3, a4)
        log("hashForPaySignature data: \(data.hexString))", type: .cryptoDetails)
        return try processor.sha3(data)
    }

    private func hashForMoveSignature(teamID: Int, opNum: Int, addresses: [String]) throws -> Data {
        let hex = Hex()
        let a0 = Constant.nsPrefix // prefix, that is used in the contract to indicate a signature for move tx.
        let a1 = String(format: "%064x", teamID)
        let a2 = String(format: "%064x", opNum)
        let a3: [String] = addresses.map { address in hex.truncatePrefix(string: address) }
        let data = try hex.data(from: a0, a1, a2, a3)
        return try processor.sha3(data)
    }

    private  func publishMove(tx: Tx, completion: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
         log("Publishing move tx: \(tx.id.uuidString)", type: .crypto)
        let inputs = tx.inputs
        guard inputs.count == 1 else {
            let error = EthWalletError.unexpectedTxInputsCount(count: inputs.count, txID: tx.id.uuidString)
            failure(error)
            return
        }
        guard let myMultisig = tx.fromMultisig else {
            failure(EthWalletError.noMultisigs)
            return
        }

        checkMyNonce(success: { myNonce in
            let gasLimit = Constant.gasLimitForMoveTx
            self.refreshGasPrice { gasPrice in
                guard let multisigAddress = myMultisig.address, let moveFrom = tx.inputs.first else {
                    return
                }

                let methodID = Constant.methodIDchangeAllCosigners
                let opNum = moveFrom.previousTransactionIndex + 1
                guard let toMultisig = tx.toMultisig else {
                    failure(EthWalletError.noToMultisig)
                    return
                }

                let nextCosignerAddresses = self.toCosignerAddresses(nextMultisig: toMultisig)

                var sig: [Data] = [Data(), Data(), Data()]
                var pos: [Int] = [0, 0, 0]
                var txSignatures: [Int: TxSignature] = [:]

                for input in tx.inputs {
                    guard let signatures = input.signaturesValue as? Set<TxSignature> else { continue }

                    for signature in signatures {
                        txSignatures[signature.teammateID] = signature
                    }
                }

                // CHECK: should cosigners be from fromMultisig or toMultisig
                guard let cosigners = tx.fromMultisig?.cosigners else {
                    failure(EthWalletError.noFromMultisig)
                    return
                }

                var j = 0
                for (idx, cosigner) in cosigners.enumerated() {
                    if let id = cosigner.teammate?.id, let s = txSignatures[id] {
                        pos[j] = idx
                        sig[j] = s.signature
                        j += 1
                        if j >= 3 {
                            break
                        }
                    }
                }

                log("sigs: \(sig.count), positions: \(pos)", type: .cryptoDetails)
                guard (sig.count < 3 && sig.count < txSignatures.count) == false else {
                    print("""
                        tx was skipped. One or more signatures are not from a valid cosigner. \
                        Total signatures: \(txSignatures.count)  Valid signatures: \(sig.count) \
                        positions: \(pos) Tx.id: \(tx.id)
                        """)
                    failure(EthWalletError.invalidCosigner(txID: tx.id.uuidString))
                    return
                }

                var args: [Any] = [opNum, nextCosignerAddresses]
                args += pos as [Any]
                args += sig as [Any]

                log("args: \(args)", type: .cryptoDetails)
                do {
                    let cryptoTx = try self.processor.messageTx(nonce: myNonce,
                                                                gasLimit: gasLimit,
                                                                contractAddress: multisigAddress,
                                                                gasPrice: gasPrice,
                                                                methodID: methodID,
                                                                arguments: args)
                    let signedTx = try self.processor.signTx(unsignedTx: cryptoTx, isTestNet: self.isTestNet)
                    self.publish(cryptoTx: signedTx, completion: { hash in
                        completion(hash)
                    }, failure: failure)
                } catch {
                    failure(error)
                }
            }
        }) { error in
            failure(error)
        }
    }

    private  func publishPay(tx: Tx, completion: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        log("Publishing tx: \(tx.id.uuidString)", type: .crypto)
        let inputs = tx.inputs
        guard inputs.count == 1 else {
            let error = EthWalletError.unexpectedTxInputsCount(count: inputs.count, txID: tx.id.uuidString)
            failure(error)
            return
        }
        guard let myMultisig = tx.fromMultisig else {
            failure(EthWalletError.noMultisigs)
            return
        }

        checkMyNonce(success: { myNonce in
            let gasLimit = Constant.gasLimitBase + Constant.gasStash * tx.outputs.count
            self.refreshClaimGasPrice { gasPrice in
                guard let multisigAddress = myMultisig.address, let payFrom = tx.inputs.first else {
                    return
                }

                let methodID = Constant.methodIDtransfer

                let opNum = payFrom.previousTransactionIndex + 1
                log("Publish move with opNum: \(opNum)", type: .cryptoDetails)
                let payToAddresses = self.toAddresses(destinations: tx.outputs)
                log("Pay to addresses: \(payToAddresses)", type: .cryptoDetails)
                let payToValues = self.toValues(destinations: tx.outputs)
                log("Pay to values: \(payToValues)", type: .cryptoDetails)

                var sig: [Data] = [Data(), Data(), Data()]
                var pos: [Int] = [0, 0, 0]
                var txSignatures: [Int: TxSignature] = [:]
                log("Creating dictionary of signatures", type: .cryptoDetails)
                for input in tx.inputs {
                    guard let signatures = input.signaturesValue as? Set<TxSignature> else {
                        log("Input \(input) had no signatures", type: [.cryptoDetails, .error])
                        continue
                    }

                    for signature in signatures {
                        log("associating \(signature), with \(signature.teammateID)", type: .cryptoDetails)
                        txSignatures[signature.teammateID] = signature
                    }
                }

                guard let cosigners = tx.fromMultisig?.cosigners else {
                    failure(EthWalletError.noFromMultisig)
                    return
                }

                var j = 0
                for (idx, cosigner) in cosigners.enumerated() {
                    if let id = cosigner.teammate?.id, let s = txSignatures[id] {
                        pos[j] = idx
                        sig[j] = s.signature
                        log("Added signature: \(s.signature) to position \(idx)", type: .cryptoDetails)
                        j += 1
                        if j >= 3 {
                            break
                        }
                    } else {
                        log("Did not add: \(cosigner)", type: .cryptoDetails)
                    }
                }

                log("sigs: \(sig.count), positions: \(pos)", type: .cryptoDetails)
                guard (sig.count < 3 && sig.count < txSignatures.count) == false else {
                    print("""
                        tx was skipped. One or more signatures are not from a valid cosigner. \
                        Total signatures: \(txSignatures.count)  Valid signatures: \(sig.count) \
                        positions: \(pos) Tx.id: \(tx.id)
                        """)
                    failure(EthWalletError.invalidCosigner(txID: tx.id.uuidString))
                    return
                }

                var args: [Any] = [opNum, payToAddresses, payToValues]
                args += pos as [Any]
                args += sig as [Any]

                log("args: \(args)", type: .cryptoDetails)
                do {
                    let cryptoTx = try self.processor.messageTx(nonce: myNonce,
                                                                gasLimit: gasLimit,
                                                                contractAddress: multisigAddress,
                                                                gasPrice: gasPrice,
                                                                methodID: methodID,
                                                                arguments: args)
                    let signedTx = try self.processor.signTx(unsignedTx: cryptoTx, isTestNet: self.isTestNet)
                    self.publish(cryptoTx: signedTx, completion: { hash in
                        completion(hash)
                    }, failure: failure)
                } catch {
                    failure(error)
                }
            }
        }) { error in
            failure(error)
        }
    }
    
}
