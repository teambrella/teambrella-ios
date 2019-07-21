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
        case cryptoBalance = "CryptoBalance"
        case cryptoReserved = "CryptoReserved"
        case defaultWithdrawAddress = "DefaultWithdrawAddress"
        case warning = "Warning"
    }
    
    let txs: [WithdrawTx]
    let cryptoBalance: Ether
    let cryptoReserved: Ether
    let defaultWithdrawAddress: EthereumAddress?
    let warning: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        txs = try container.decode([WithdrawTx].self, forKey: .txs)
        cryptoBalance = try container.decode(Ether.self, forKey: .cryptoBalance)
        cryptoReserved = try container.decode(Ether.self, forKey: .cryptoReserved)
        warning = try container.decode(String.self, forKey: .warning)
        let address = try? container.decode(EthereumAddress.self, forKey: .defaultWithdrawAddress)
        defaultWithdrawAddress = address
    }
 
}
