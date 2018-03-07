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

class EtherNode {
    struct Constant {
        static let testAuthority: String = "https://ropsten.etherscan.io/"
        static let mainAuthority: String = "http://api.etherscan.io/"
    }
    
    enum EtherNodeError: Error {
        case malformedString(String)
    }
    
    private let ethereumAPI: EtherAPI
    private var isTestNet: Bool
    
    init(isTestNet: Bool) {
        self.isTestNet = isTestNet
        
        let authority = isTestNet ? Constant.testAuthority : Constant.mainAuthority
            ethereumAPI = EtherAPI(server: authority)
    }
    
    func pushTx(hex: String, success: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
         ethereumAPI.pushTx(hex: hex, success: { string in
            success(string)
        }, failure: { error in
            failure(error)
        })
    }
    
    func checkNonce(addressHex: String, success: @escaping (Int) -> Void, failure: @escaping (Error?) -> Void) {
        ethereumAPI.checkNonce(address: addressHex, success: { string in
            guard let nonce = Int(hexString: string) else {
                    failure(EtherNodeError.malformedString(string))
                    return
            }
            
            success(nonce)
        }, failure: { error in
            failure(error)
        })
    }
    
    func checkTx(creationTx: String, success: @escaping (TxReceipt) -> Void, failure: @escaping (Error?) -> Void) {
        ethereumAPI.checkTx(hash: creationTx, success: success, failure: failure)
    }
    
    func checkBalance(address: String, success: @escaping (Decimal) -> Void, failure: @escaping (Error) -> Void) {
        ethereumAPI.checkBalance(address: address, success: success, failure: failure)
    }

}
