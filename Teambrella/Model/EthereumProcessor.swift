//
//  Ethereum.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Geth

/**
 * Interaction with Ethereum wallet
 */
 struct EthereumProcessor {
    /// creates a processor with the key that is stored for the current user
    static var standard: EthereumProcessor { return EthereumProcessor(key: service.server.key) }
    
    private var key: Key
    
    /// BTC key
    private var secretData: Data { return key.key.privateKey as Data }
    /// BTC WiF
    private var secretString: String? { return key.isTestnet ? key.key.wifTestnet : key.key.wif }
    
    var ethAddressString: String? {
        return ethAddress?.getHex()
    }
    
    var ethKeyStore: GethKeyStore? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return GethNewKeyStore(documentsPath + "/keystore" + key.publicKey, GethLightScryptN, GethLightScryptP)
    }
    var ethAccount: GethAccount? {
        guard let keyStore = ethKeyStore else { return nil }
        guard let accounts = keyStore.getAccounts() else { return nil }
        guard let secretString = secretString else { return nil }
        
        return accounts.size() == 0
        ? try? keyStore.importECDSAKey(secretData, passphrase: secretString)
        : try? accounts.get(0)
    }
    var ethAddress: GethAddress? {
        return ethAccount?.getAddress()
    }
    
    var publicKeySignature: String? {
        guard let signature: Data = sign(publicKey: key.publicKey) else { return nil }
        
        return "0x" + reverseAndCalculateV(data: signature).hexString
    }
    
    init(key: Key) {
        self.key = key
    }
    
    func sign(publicKey: String) -> Data? {
        // signing last 32 bytes of a string
        guard let keyStore = ethKeyStore else { return nil }
        guard let account = ethAccount else { return nil }
        guard let data = publicKey.data(using: .utf8) else { return nil }
        
        var bytes: [UInt8] = Array(data)
        guard bytes.count >= 32 else { return nil }
        
        let last32bytes = bytes[(bytes.count - 32)...]
        guard let secretWiF = secretString else { return nil }
        
        do {
            let signed = try keyStore.signHashPassphrase(account, passphrase: secretWiF, hash: Data(last32bytes))
            return signed
        } catch {
            log("Error signing ethereum: \(error)", type: .error)
            service.error.present(error: error)
            return nil
        }
    }
    
    func reverseAndCalculateV(data: Data) -> Data {
        var bytes: [UInt8] = data.reversed()
        bytes.insert(27, at: 0)
        return Data(bytes)
    }
    
}
