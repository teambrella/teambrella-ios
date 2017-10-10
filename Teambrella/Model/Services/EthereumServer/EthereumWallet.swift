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

class EthereumWallet {
    struct Constant {
        static let methodIDtransfer = "91f34dbd"
        static let txPrefix = "5452"
        static let nsPrefix = "4E53"
    }
    
    // TODO: private final EtherAccount mEtherAcc;
    private var account: Any?
    private var isTestNet: Bool
    
    init(privateKey: String, keyStorePath: String, keyStoreSecret: String, isTestNet: Bool) {
     self.isTestNet = isTestNet
    }
}
