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

class EthWallet {
    struct Constant {
        static let methodIDteamID = "8d475461"
        static let methodIDcosigners = "22c5ec0f"
        static let methodIDtransfer = "91f34dbd"
        static let txPrefix = "5452"
        static let nsPrefix = "4E53"
    }
    
    var processor: EthereumProcessor = EthereumProcessor.standard
    let isTestNet: Bool
    
    var gasPrice = 100000001
    var contractGasPrice = 100000001
    var testGasPrice = 100000001
    var testContractGasPrice = 100000001
    
    var contract: String? {
        guard let fileURL = Bundle.main.path(forResource: "Contract", ofType: "txt") else { return nil }
        
        return try? String(contentsOfFile: fileURL, encoding: String.Encoding.utf8)
    }
    
    init(isTestNet: Bool) {
        self.isTestNet = isTestNet
    }
    
    func createOneWallet(myNonce: Int, multisig: Multisig, gaslLimit: Int, gasPrice: Int) -> String? {
        let cosigners = multisig.cosigners
        guard !cosigners.isEmpty else { return nil }
        
        let addresses = cosigners.map { $0.addressID }
        guard let contract = contract else { return nil }
        
        let cryptoTx = BTCTransaction()

        return nil
    }
    
    
}
