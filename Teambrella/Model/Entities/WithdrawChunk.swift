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
import SwiftyJSON

struct WithdrawChunk {
    let txs: [WithdrawTx]
    let cryptoBalance: Decimal
    let cryptoReserved: Decimal
    let defaultWithdrawAddress: EthereumAddress
    
    init?(json: JSON) {
        guard let balance = Decimal(string: json["CryptoBalance"].stringValue),
            let reserved = Decimal(string: json["CryptoReserved"].stringValue),
            let address = EthereumAddress(string: json["DefaultWithdrawAddress"].stringValue) else { return nil }
        
        txs = json["Txs"].arrayValue.flatMap { WithdrawTx(json: $0) }
        cryptoBalance = balance
        cryptoReserved = reserved
        defaultWithdrawAddress = address
    }
    
}
