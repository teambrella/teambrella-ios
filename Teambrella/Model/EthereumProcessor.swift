//
//  Ethereum.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Geth

class EthereumProcessor {
    /*
    func ethAddress() -> String? {
        let secretData = service.server.key.key.privateKey
        let secretString = service.server.key.privateKey
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        guard let keyStore = GethNewKeyStore(documentsPath + "/keystore", GethLightScryptN, GethLightScryptP) else {
            return nil
        }
    
        if keyStore.getAccounts().size == 0 {
            - (GethAccount*)importECDSAKey:(NSData*)key passphrase:(NSString*)passphrase error:(NSError**)error;
            try? keyStore.importECDSAKey(secretData, passphrase: secretString, error: nil)
        }
        guard let account = try? keyStore.getAccounts()?.get(index: 0, error: nil) else { return nil }
        
        return account?.getAddress().getHex()
    }
 */
}
