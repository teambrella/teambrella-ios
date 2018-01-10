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

struct WithdrawChunk: Decodable {
    enum CodingKeys: String, CodingKey {
      case txs = "Txs"
        case balance = "CryptoBalance"
        case reserved = "CryptoReserved"
        case withdrawAddress = "DefaultWithdrawAddress"
    }
    
    let txs: [WithdrawTx]
    let cryptoBalance: Decimal
    let cryptoReserved: Decimal
    let defaultWithdrawAddress: EthereumAddress?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let addressString = try container.decode(String.self, forKey: .withdrawAddress)
        defaultWithdrawAddress = EthereumAddress(string: addressString)
        txs = try container.decode([WithdrawTx].self, forKey: .txs)
        cryptoBalance = try container.decode(Decimal.self, forKey: .balance)
        cryptoReserved = try container.decode(Decimal.self, forKey: .reserved)
    }
 
}
