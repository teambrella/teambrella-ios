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

struct ServerReply {
    let status: ServerStatus
    let paging: PagingInfo?
    let json: Any
    let string: String?
    let bool: Bool?

    var data: Data {
        switch json {
        case _ as String:
            fatalError("Don't use data. Use string instead")
        case _ as Bool:
            fatalError("Don't use data. Use bool instead")
        case _ as NSNull:
            return Data()
        default:
            do {
                return try JSONSerialization.data(withJSONObject: json, options: [])
            } catch {
                log("ServerReply parse error: \(error)\n Data: \(json)", type: .error)
                return Data()
            }
        }
    }
    
    init(status: ServerStatus, paging: PagingInfo?, json: Any) {
        self.status = status
        self.paging = paging
        self.json = json
        self.string = nil
        self.bool = nil
    }
    
    init(data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
            throw TeambrellaErrorFactory.wrongReply()
        }
        guard let statusJSON = json[CodingKeys.status.rawValue] else {
            throw TeambrellaErrorFactory.emptyReplyError()
        }

        let dataJSON = json[CodingKeys.data.rawValue]
        
        let decoder = JSONDecoder()
        let statusData = try JSONSerialization.data(withJSONObject: statusJSON, options: [])

        if let pagingJSON = json[CodingKeys.paging.rawValue] {
            let pagingData = try JSONSerialization.data(withJSONObject: pagingJSON, options: [])
            paging = try decoder.decode(PagingInfo.self, from: pagingData)
        } else {
            paging = nil
        }
        status = try decoder.decode(ServerStatus.self, from: statusData)

        var string: String?
        var bool: Bool?
        switch dataJSON {
        case let value as String:
            string = value
        case let value as Bool:
            bool = value
        default:
            break
        }
        self.string = string
        self.bool = bool

        self.json = dataJSON as Any
    }

    enum CodingKeys: String {
        case status = "Status"
        case paging = "Meta"
        case data = "Data"
    }
    
}
