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

struct ServerStatus: Codable {
    enum CodingKeys: String, CodingKey {
        case resultCode = "ResultCode"
        case timestamp = "Timestamp"
        case errorMessage = "ErrorMessage"
        case recommendedVersion = "RecommendedVersion"
        case needLogs = "NeedLogs"
    }
    
    let resultCode: Int
    let timestamp: Int64
    let errorMessage: String?
    let recommendedVersion: Int
    let needLogs: Bool?
    
    var isValid: Bool { return resultCode == 0 }
    var isError: Bool { return !isValid }
}
