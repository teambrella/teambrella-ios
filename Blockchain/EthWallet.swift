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
        
        static let minGasWalletBalance: Decimal = 0.0075
        static let maxGasWalletBalance: Decimal = 0.01

        static let gasLimitBase: Int = 100_000
        static let gasLimitForMoveTx: Int = 200_000
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
        guard let fileURL = Bundle.main.path(forResource: "Contract", ofType: "txt") else { return nil }
        
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
        
        let addresses = cosigners.flatMap { $0.teammate.address }
        guard let contract = contract else {
            failure(EthWalletError.contractDoesNotExist)
            return
        }
        
        do {
            var cryptoTx = try processor.contractTx(nonce: myNonce,
                                                    gasLimit: gaslLimit,
                                                    gasPrice: gasPrice,
                                                    byteCode: contract,
                                                    arguments: [addresses, multisig.teamID])
            cryptoTx = try processor.signTx(unsignedTx: cryptoTx, isTestNet: isTestNet)
            log("CryptoTx created teamID: \(multisig.teamID), tx: \(cryptoTx)", type: .cryptoDetails)
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
        
        //let blockchain = EtherNode(isTestNet: isTestNet)
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
                self.gasPrice = 100_000_001
            case 50_000_000_001...:
                log("The server is kidding with us about the gas price: \(price)", type: [.error, .crypto])
                self.gasPrice = 50_000_000_001
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
                self.contractGasPrice = 100_000_001
            case 8_000_000_002...:
                log("The server is kidding with us about the contract gas price: \(price)", type: [.error, .crypto])
                self.contractGasPrice = 8_000_000_001
            default:
                self.contractGasPrice = price
            }
            completion(self.contractGasPrice)
        }
    }

    func deposit(multisig: Multisig, completion: @escaping (Bool) -> Void) {
        guard let address = processor.ethAddressString else { return }
        
        blockchain.checkBalance(address: address, success: { gasWalletAmount in
            print("balance is \(gasWalletAmount)")
            if gasWalletAmount > Constant.maxGasWalletBalance {
                self.refreshGasPrice(completion: { gasPrice in
                    self.blockchain.checkNonce(addressHex: address, success: { nonce in
                        let value = gasWalletAmount - Constant.minGasWalletBalance
                        do {
                            var tx = try self.processor.depositTx(nonce: nonce,
                                                                  gasLimit: 50000,
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
            }
        }, failure: { error in
            log("Check balance failed with \(String(describing: error))", type: [.error, .crypto])
            completion(false)
        })
    }

    func cosign(transaction: Tx, payOrMoveFrom: TxInput) throws -> Data {
        guard let kind = transaction.kind else {
            fatalError()
        }

        switch kind {
        case .moveToNextWallet:
            return cosignMove(transaction: transaction, moveFrom: payOrMoveFrom)
        default:
            return try cosignPay(transaction: transaction, payFrom: payOrMoveFrom)
        }
    }

    // MARK: TODO
    /**
     Android version:

     int opNum = payFrom.previousTxIndex + 1;

     Multisig sourceMultisig = tx.getFromMultisig();
     long teamId = sourceMultisig.teamId;

     String[] payToAddresses = toAddresses(tx.txOutputs);
     String[] payToValues = toValues(tx.txOutputs);

     byte[] h = getHashForPaySignature(teamId, opNum, payToAddresses, payToValues);
     Log.v(LOG_TAG, "Hash created for Tx transfer(s): " + Hex.fromBytes(h));

     byte[] sig = mEtherAcc.signHashAndCalculateV(h);
     Log.v(LOG_TAG, "Hash signed.");

     return sig;
     */
    func cosignPay(transaction: Tx, payFrom: TxInput) throws -> Data {
        let opNum = payFrom.previousTransactionIndex + 1
        guard let sourceMultisig = transaction.fromMultisig else {
            fatalError("There is no from Multisig")
        }

        let teamID = sourceMultisig.teamID
        let payToAddresses = toAddresses(destinations: transaction.outputs)
        let payToValues = toValues(destinations: transaction.outputs)

        let h = try hashForPaySignature(teamID: teamID, opNum: opNum, addresses: payToAddresses, values: payToValues)
        log("Hash created for Tx transfer(s): \(h.base64EncodedString())", type: .cryptoDetails)

        let sig = try processor.signHashAndCalculateV(hash256: h)

        log("Hash signed.", type: .cryptoDetails)

        return sig
    }

    func cosignMove(transaction: Tx, moveFrom: TxInput) -> Data {
        /*
         int opNum = moveFrom.previousTxIndex + 1;

         Multisig sourceMultisig = tx.getFromMultisig();
         long teamId = sourceMultisig.teamId;

         String[] nextCosignerAddresses = toCosignerAddresses(tx.getToMultisig());
         byte[] h = getHashForMoveSignature(teamId, opNum, nextCosignerAddresses);
         Log.v(LOG_TAG, "Hash created for Tx transfer(s): " + Hex.fromBytes(h));

         byte[] sig = mEtherAcc.signHashAndCalculateV(h);
         Log.v(LOG_TAG, "Hash signed.");

         return sig;
         */
        return Data()
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

    /**
     Android version:

     int n = destinations.size();
     String[] destinationAddresses = new String[n];

     for (int i = 0; i < n; i++) {
     destinationAddresses[i] = destinations.get(i).address;
     sanityAddressCheck(destinationAddresses[i]);
     }

     return destinationAddresses;
     */
    private func toAddresses(destinations: [TxOutput]) -> [String] {
        let destinationAddresses: [String] = destinations.flatMap { output in output.saneAddress()?.string }
        return destinationAddresses
    }

    /**
     Android version:

     int n = destinations.size();
     String[] destinationValues = new String[n];

     for (int i = 0; i < n; i++) {
     destinationValues[i] = AbiArguments.parseDecimalAmount(destinations.get(i).cryptoAmount);
     }

     return destinationValues;
     */
    private func toValues(destinations: [TxOutput]) -> [String] {
        let destinationValues = destinations.flatMap { output in
            guard let stringValue = output.amountValue?.stringValue else { return nil }

            return AbiArguments.parseDecimalAmount(decimalAmount: stringValue)
        }
        return destinationValues
    }

    /**
     Android version:

     String a0 = TX_PREFIX; // prefix, that is used in the contract to indicate a signature for transfer tx
     String a1 = String.format("%064x", teamId);
     String a2 = String.format("%064x", opNum);
     int n = addresses.length;
     String[] a3 = new String[n];
     for (int i = 0; i < n; i++) {
     a3[i] = Hex.remove0xPrefix(addresses[i]);
     }
     String[] a4 = new String[n];
     for (int i = 0; i < n; i++) {
     a4[i] = Hex.remove0xPrefix(values[i]);
     }

     byte[] data = com.teambrella.android.blockchain.Hex.toBytes(a0, a1, a2, a3, a4);
     return Sha3.getKeccak256Hash(data);
     */
    private func hashForPaySignature(teamID: Int, opNum: Int, addresses: [String], values: [String]) throws -> Data {
        let a0 = Constant.txPrefix // prefix, that is used in the contract to indicate a signature for transfer tx
        let a1 = String(format: "%064x", teamID)
        let a2 = String(format: "%064x", opNum)
        let hex = Hex()
        let a3: [String] = addresses.map { address in hex.truncatePrefix(string: address) }
        let a4: [String] = values.map { value in hex.truncatePrefix(string: value) }

        let data = try hex.data(from: a0, a1, a2, a3, a4)

        return processor.sha3(data)
    }

    private  func publishMove(tx: Tx, completion: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        /*
         Android version:

         List<TxInput> inputs = tx.txInputs;
         if (inputs.size() != 1) {
         String msg = "Unexpected count of move tx inputs of ETH tx. Expected: 1, was: " + inputs.size() + ". (tx ID: " + tx.id + ")";
         Log.e(LOG_TAG, msg);
         if (!BuildConfig.DEBUG) {
         Crashlytics.log(msg);
         }

         return null;
         }

         Multisig myMultisig = tx.getFromMultisig();
         long myNonce = getMyNonce();
         long gasLimit = 200_000L;
         long gasPrice = getGasPrice();
         String multisigAddress = myMultisig.address;
         String methodId = METHOD_ID_CHANGEALLCOSIGNERS;

         TxInput moveFrom = tx.txInputs.get(0);
         int opNum = moveFrom.previousTxIndex + 1;
         String[] nextCosignerAddresses = toCosignerAddresses(tx.getToMultisig());

         int[] pos = new int[3];
         byte[][] sig = new byte[3][];
         sig[0] = sig[1] = sig[2] = new byte[0];
         Map<Long, TXSignature> txSignatures = moveFrom.signatures;
         int index = 0, j = 0;
         for (Cosigner cos : tx.cosigners) {
         if (txSignatures.containsKey(cos.teammateId)) {
         TXSignature s = txSignatures.get(cos.teammateId);
         pos[j] = index;
         sig[j] = s.bSignature;

         if (++j >= 3) {
         break;
         }
         }

         index++;
         }
         if (j < txSignatures.size() && j < 3){
         Log.reportNonFatal(LOG_TAG, "tx was skipped. One or more signatures are not from a valid cosigner. Total signatures: " + txSignatures.size() + ". Valid signatures: " + j +
         ". pos[0]: " + pos[0] + "" + ". pos[1]: " + pos[1] + ". pos[2]: " + pos[2] + ". Tx.id: " + tx.id);
         return null;
         }

         Transaction cryptoTx = mEtherAcc.newMessageTx(myNonce, gasLimit, multisigAddress, gasPrice, methodId, opNum, nextCosignerAddresses, pos[0], pos[1], pos[2], sig[0], sig[1], sig[2]);
         if (cryptoTx == null){
         Log.w(LOG_TAG, "move tx was skipped. Seek details in the log above. Tx.id: " + tx.id);
         return null;
         }

         try {
         Log.v(LOG_TAG, "move tx created: " + cryptoTx.encodeJSON());
         } catch (Exception e) {
         Log.e(LOG_TAG, "could not encode JSON to log move tx: " + e.getMessage(), e);
         }

         cryptoTx = mEtherAcc.signTx(cryptoTx, mIsTestNet);
         Log.v(LOG_TAG, "move tx signed.");

         return publish(cryptoTx);
         */
    }

    private  func publishPay(tx: Tx, completion: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        /*
         Android version:

         List<TxInput> inputs = tx.txInputs;
         if (inputs.size() != 1) {
         String msg = "Unexpected count of tx inputs of ETH tx. Expected: 1, was: " + inputs.size() + ". (tx ID: " + tx.id + ")";
         Log.e(LOG_TAG, msg);
         if (!BuildConfig.DEBUG) {
         Crashlytics.log(msg);
         }

         return null;
         }

         Multisig myMultisig = tx.getFromMultisig();
         long myNonce = getMyNonce();
         long gasLimit = 500_000L;
         long gasPrice = getGasPriceForClaim();
         String multisigAddress = myMultisig.address;
         String methodId = METHOD_ID_TRANSFER;

         TxInput payFrom = tx.txInputs.get(0);
         int opNum = payFrom.previousTxIndex + 1;
         String[] payToAddresses = toAddresses(tx.txOutputs);
         String[] payToValues = toValues(tx.txOutputs);

         int[] pos = new int[3];
         byte[][] sig = new byte[3][];
         sig[0] = sig[1] = sig[2] = new byte[0];
         Map<Long, TXSignature> txSignatures = payFrom.signatures;
         int index = 0, j = 0;
         for (Cosigner cos : tx.cosigners) {
         if (txSignatures.containsKey(cos.teammateId)) {
         TXSignature s = txSignatures.get(cos.teammateId);
         pos[j] = index;
         sig[j] = s.bSignature;

         if (++j >= 3) {
         break;
         }
         }

         index++;
         }
         if (j < txSignatures.size() && j < 3){
         Log.reportNonFatal(LOG_TAG, "tx was skipped. One or more signatures are not from a valid cosigner. Total signatures: " + txSignatures.size() + ". Valid signatures: " + j +
         ". pos[0]: " + pos[0] + "" + ". pos[1]: " + pos[1] + ". pos[2]: " + pos[2] + ". Tx.id: " + tx.id);
         return null;
         }

         Transaction cryptoTx = mEtherAcc.newMessageTx(myNonce, gasLimit, multisigAddress, gasPrice, methodId, opNum, payToAddresses, payToValues, pos[0], pos[1], pos[2], sig[0], sig[1], sig[2]);
         if (cryptoTx == null){
         Log.w(LOG_TAG, "tx was skipped. Seek details in the log above. Tx.id: " + tx.id);
         return null;
         }

         try {
         Log.v(LOG_TAG, "tx created: " + cryptoTx.encodeJSON());
         } catch (Exception e) {
         Log.e(LOG_TAG, "could not encode JSON to log tx: " + e.getMessage(), e);
         }

         cryptoTx = mEtherAcc.signTx(cryptoTx, mIsTestNet);
         Log.v(LOG_TAG, "tx signed.");

         return publish(cryptoTx);
         */
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
        guard let teammate = tx.teammate else {
            failure(EthWalletError.transactionHasNoTeammate)
            return
        }

        checkMyNonce(success: { myNonce in
            let gasLimit = Constant.gasLimitBase + 30_000 * tx.outputs.count
            self.refreshGasPrice { gasPrice in
                guard let multisigAddress = myMultisig.address, let payFrom = tx.inputs.first else {
                    return
                }

                let methodID = Constant.methodIDtransfer

                let opNum = payFrom.previousTransactionIndex + 1
                let payToAddresses = self.toAddresses(destinations: tx.outputs)
                let payToValues = self.toValues(destinations: tx.outputs)

                var sig: [Data] = []
                sig.append(Data())
                sig.append(Data())
                sig.append(Data())

                var pos: [Int] = []
                var txSignatures: [Int: TxSignature] = [:]
                for input in tx.inputs {
                    guard let signatures = input.signaturesValue as? Set<TxSignature> else { continue }

                    for signature in signatures {
                        txSignatures[signature.teammateID] = signature
                    }
                }
                //  Map<Long, TXSignature> txSignatures = payFrom.signatures;
               
//                var index: Int = 0
                var j: Int = 0

                let cosigners = Cosigner.cosigners(for: teammate)
                for (idx, cosigner) in cosigners.enumerated() {
                    if let s = txSignatures[cosigner.teammate.id] {
                        pos[j] = idx
                        sig[j] = s.signature
                        j += 1
                        if j >= 3 {
                            break
                        }
                    }
                }

                guard (j < txSignatures.count && j < 3) == false else {
                    print("""
                        tx was skipped. One or more signatures are not from a valid cosigner. \
                        Total signatures: \(txSignatures.count)  Valid signatures: \(j) \
                        pos[0]: \(pos[0]) pos[1]: \(pos[1]) pos[2]: \(pos[2]) Tx.id: \(tx.id)
                        """)
                    failure(EthWalletError.invalidCosigner(txID: tx.id.uuidString))
                    return
                }
                guard pos.count >= 3, sig.count >= 3 else {
                    failure(EthWalletError.argumentsMismatch(args: [pos, sig]))
                    return
                }

                let args: [Any] = [opNum, payToAddresses, payToValues, pos[0], pos[1], pos[2], sig[0], sig[1], sig[2]]
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
