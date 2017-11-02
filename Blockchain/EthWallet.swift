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

import Foundation
import Geth

class EthWallet {
    struct Constant {
        static let methodIDteamID = "8d475461"
        static let methodIDcosigners = "22c5ec0f"
        static let methodIDtransfer = "91f34dbd"
        static let txPrefix = "5452"
        static let nsPrefix = "4E53"
    }
    
    let processor: EthereumProcessor
    let isTestNet: Bool
    
    var gasPrice: Int { return isTestNet ? 100000001 : 100000001 }
    var contractGasPrice: Int { return isTestNet ? 100000001 : 100000001 }
    
    var contract: String? {
        guard let fileURL = Bundle.main.path(forResource: "Contract", ofType: "txt") else { return nil }
        
        return try? String(contentsOfFile: fileURL, encoding: String.Encoding.utf8)
    }
    
    init(isTestNet: Bool, processor: EthereumProcessor) {
        self.isTestNet = isTestNet
        self.processor = processor
    }
    
    enum EthWalletError: Error {
        case multisigHasNoCosigners(Int)
        case contractDoesNotExist
        case multisigHasNoCreationTx(Int)
        case allGasUsed
    }
    
    func createOneWallet(myNonce: Int,
                         multisig: Multisig,
                         gaslLimit: Int,
                         gasPrice: Int,
                         completion: @escaping (String) -> Void,
                         failure: @escaping (Error?) -> Void) {
        let cosigners = multisig.cosigners
        guard !cosigners.isEmpty else {
            log("Multisig address id: \(multisig.id) has no cosigners", type: [.error, .crypto])
            failure(EthWalletError.multisigHasNoCosigners(multisig.id))
            return
        }
        guard let creationTx = multisig.creationTx else {
            failure(EthWalletError.multisigHasNoCreationTx(multisig.id))
            return
        }
        
        let addresses = cosigners.map { $0.multisig.addressValue }
        guard let contract = contract else {
            failure(EthWalletError.contractDoesNotExist)
            return
        }
        
        do {
            var cryptoTx = try processor.contractTx(nonce: myNonce,
                                                    gasLimit: gaslLimit,
                                                    gasPrice: gasPrice,
                                                    byteCode: contract,
                                                    arguments: addresses,
                                                    multisig.teamID)
            cryptoTx = try processor.signTx(unsignedTx: cryptoTx, isTestNet: isTestNet)
            log("Multisig created teamID: \(multisig.teamID), tx: \(creationTx)", type: .crypto)
            publish(cryptoTx: cryptoTx, completion: completion, failure: failure)
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
            let blockchain = EtherNode(isTestNet: isTestNet)
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
        
        let blockchain = EtherNode(isTestNet: isTestNet)
        blockchain.checkNonce(addressHex: address, success: { nonce in
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
                            failure: @escaping (Error?) -> Void) {
        guard let creationTx = multisig.creationTx else { return }
        
        let blockchain = EtherNode(isTestNet: isTestNet)
        blockchain.checkTx(creationTx: creationTx, success: { txReceipt in
            let gasUsed = Int(hexString: txReceipt.gasUsed)
            let isAllGasUsed = gasUsed == gasLimit
            if !isAllGasUsed {
                success(txReceipt.contractAddress)
            } else {
                failure(EthWalletError.allGasUsed)
            }
        }) { error in
            failure(error)
        }
    }
    
}
