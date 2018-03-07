//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct GasStation {
    typealias CompletionHandler = (Int, Error?) -> Void

    let server: BlockchainServer

    init(server: BlockchainServer = BlockchainServer()) {
        self.server = server
    }

    func gasPrice(completion: @escaping CompletionHandler) {
        server.fetch(urlString: "api/eth_gasPrice", success: { data in
            if let string = String(data: data, encoding: .utf8), let value = Int(string) {
                 completion(value, nil)
            } else {
                completion(-1, GasStationError.fetchResponseCorrupted(data))
            }
        }, failure: { error in
            completion(-1, error)
        })
    }

    func contractCreationGasPrice(completion: @escaping CompletionHandler) {
        server.fetch(urlString: "api/eth_gasPrice/ContractCreation", success: { data in
            if let string = String(data: data, encoding: .utf8), let value = Int(string) {
                completion(value, nil)
            } else {
                completion(-1, GasStationError.fetchResponseCorrupted(data))
            }
        }, failure: { error in
            completion(-1, error)
        })
    }

    enum GasStationError: Error {
        case fetchResponseCorrupted(Data)
    }

}
