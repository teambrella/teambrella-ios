//
//  Ethereum.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.09.17.
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
//

import BigNumber
import ExtensionsPack
import Foundation
import Geth

/**
 * Interaction with Ethereum wallet
 */
struct EthereumProcessor {
    enum EthereumProcessorError: Error {
        case noKeyStore
        case noAccount
        case noWIF
        case inconsistentTxData(String)
        case wrongNumber
        case failedSHA3Hash(String)
    }
    
    /// creates a processor with the key that is stored for the current user
//    static var standard: EthereumProcessor { return EthereumProcessor(key: service.server.key) }

    var key: Key
    
    /// BTC key
    private var secretData: Data { return key.privateKeyData }
    /// BTC WiF
    private var secretString: String { return key.privateKey }
    
    var ethAddressString: String? {
        return ethAddress?.getHex()
    }
    
    var ethKeyStore: GethKeyStore? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keyStore = GethNewKeyStore(documentsPath + "/keystore" + key.publicKey, GethLightScryptN, GethLightScryptP)
        return keyStore
    }
    
    var ethAccount: GethAccount? {
        guard let keyStore = ethKeyStore else {
            log("no keystore", type: [.error, .crypto])
            return nil
        }
        guard let accounts = keyStore.getAccounts() else {
            log("no geth accounts", type: [.error, .crypto])
            return nil
        }
        
        return accounts.size() == 0
            ? try? keyStore.importECDSAKey(secretData, passphrase: secretString)
            : try? accounts.get(0)
    }
    
    var ethAddress: GethAddress? {
        return ethAccount?.getAddress()
    }
    
    var publicKeySignature: String? {
        guard let signature: Data = sign(publicKey: key.publicKey) else { return nil }
        
        let publicKeySignature = reverseAndCalculateV(data: signature).hexString
        log("Public key signature: \(publicKeySignature)", type: .crypto)
        return "0x" + publicKeySignature
    }
    
    init(key: Key) {
        self.key = key
    }
    
    func sign(publicKey: String) -> Data? {
        // signing last 32 bytes of a string
        guard let account = ethAccount else { return nil }
        let data = Data(hex: publicKey)
        var bytes: [UInt8] = Array(data)
        guard bytes.count >= 32 else { return nil }
        
        let last32bytes = bytes[(bytes.count - 32)...]
        do {
            log("ethereum address: \(account.getAddress().getHex())", type: .cryptoDetails)
            log("last 32 bytes: \(Data(last32bytes).hexString)", type: .cryptoDetails)
            log("secret string: \(secretString)", type: .cryptoDetails)
            let signed = try ethKeyStore?.signHashPassphrase(account, passphrase: secretString, hash: Data(last32bytes))
            log("signature: \(signed?.hexString ?? "nil")", type: .cryptoDetails)
            return signed
        } catch {
            log("Error signing ethereum: \(error)", type: [.error, .crypto])
            //service.error.present(error: error)
            return nil
        }
    }
    
    func reverseAndCalculateV(data: Data) -> Data {
        var bytes: [UInt8] = data.reversed()
        bytes[0] += 27
        return Data(bytes)
    }
    
    // MARK: Transaction
    
    func contractTx(nonce: Int,
                    gasLimit: Int,
                    gasPrice: Int,
                    byteCode: String,
                    arguments: [Any]) throws -> GethTransaction {
        let input = try AbiArguments.encodeToHex(args: arguments)
        let dict = ["nonce": "0x\(nonce.hexString)",
            "gasPrice": "0x\(gasPrice.hexString)",
            "gas": "0x\(gasLimit.hexString)",
            "value": "0x0",
            "input": "0x\(byteCode + input)",
            "v": "0x29",
            "r": "0x29",
            "s": "0x29"
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        let json = String(bytes: jsonData, encoding: .utf8) ?? ""
        if let tx = GethTransaction(fromJSON: json) {
            return tx
        } else {
            throw EthereumProcessorError.inconsistentTxData(json)
        }
    }
    
    func depositTx(nonce: Int,
                   gasLimit: Int,
                   toAddress: String,
                   gasPrice: Int,
                   value: Decimal) throws -> GethTransaction {
        let weis = value * 1_000_000_000_000_000_000
        guard let weisHex = BInt((weis as NSDecimalNumber).stringValue)?.asString(radix: 16) else {
            throw EthereumProcessorError.wrongNumber
        }
        
        let dict = ["nonce": "0x\(nonce.hexString)",
            "gasPrice": "0x\(gasPrice.hexString)",
            "gas": "0x\(gasLimit.hexString)",
            "to": "\(toAddress)",
            "value": "0x\(weisHex)",
            "input": "0x",
            "v": "0x29",
            "r": "0x29",
            "s": "0x29"]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        let json = String(bytes: jsonData, encoding: .utf8) ?? ""
        guard let tx = GethTransaction(fromJSON: json) else { throw EthereumProcessorError.inconsistentTxData(json) }
        
        return  tx
    }

    func messageTx(nonce: Int,
                   gasLimit: Int,
                   contractAddress: String,
                   gasPrice: Int,
                   methodID: String,
                   arguments: [Any]) throws -> GethTransaction {
        let args = try AbiArguments.encodeToHex(args: arguments)
        let dict = ["nonce": "0x\(nonce.hexString)",
            "gasPrice": "0x\(gasPrice.hexString)",
            "gas": "0x\(gasLimit.hexString)",
            "to": "\(contractAddress)",
            "value": "0x0",
            "input": "0x\(methodID)\(args)",
            "v": "0x29",
            "r": "0x29",
            "s": "0x29"]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        let json = String(bytes: jsonData, encoding: .utf8) ?? ""
        guard let tx = GethTransaction(fromJSON: json) else { throw EthereumProcessorError.inconsistentTxData(json) }

        return  tx
    }
    
    func signTx(unsignedTx: GethTransaction, isTestNet: Bool) throws -> GethTransaction {
        guard let keyStore = ethKeyStore else { throw EthereumProcessorError.noKeyStore }
        guard let account = ethAccount else { throw EthereumProcessorError.noAccount }
        
        let chainID = self.chainID(isTestNet: isTestNet)
        let passphrase = secretString
        let signed = try keyStore.signTxPassphrase(account,
                                                   passphrase: passphrase,
                                                   tx: unsignedTx,
                                                   chainID: chainID)
        return signed 
    }
    
    func chainID(isTestNet: Bool) -> GethBigInt {
        return GethBigInt(isTestNet ? 3: 1)
    }
    
    /// returns hash made by Keccak algorithm
    func sha3(_ string: String) throws -> Data {
        let hash = GethHash(fromHex: string)
        guard let hashData = hash?.getBytes() else {
            throw EthereumProcessorError.failedSHA3Hash(string)
        }
        return hashData
    }
    
    /// returns hash made by Keccak algorithm
    func sha3(_ data: Data) throws -> Data {
        let hash = GethHash(fromBytes: data)
        guard let hashData = hash?.getBytes() else {
            let string = data.hexString
            log("Error getting sha3 hash from data: \(string)", type: [.crypto, .error])
            return try sha3(string)
        }

        return hashData
    }

    func signHash(hash256: Data) throws -> Data {
        guard let account = ethAccount else { throw EthereumProcessorError.noAccount }
        guard let keyStore = ethKeyStore else { throw EthereumProcessorError.noKeyStore }

        let signed = try keyStore.signHashPassphrase(account, passphrase: secretString, hash: hash256)
        log("signed hash 256: \(signed.hexString)", type: .crypto)
        return signed
    }

    func signHashAndCalculateV(hash256: Data) throws -> Data {
        var sig: [UInt8] = try Array(signHash(hash256: hash256))
        sig[sig.count - 1] += 27
        return Data(sig)
    }
    
}
