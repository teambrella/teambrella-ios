//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

struct ServerReplyBox<T: Decodable>: Decodable, CustomStringConvertible {
    let status: ServerStatus
    let paging: PagingInfo?
    let data: T?
    
    var description: String {
        if let data = data {
            let pagingInfo = paging?.description ?? ""
            return "🎁{\(type(of: data))} \(pagingInfo)"
        } else if status.isError {
            return "🎁{error: \(status.resultCode)"
        } else {
            return "🎁{Nothing}"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case data = "Data"
        case paging = "Meta"
    }
}
