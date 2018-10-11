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

struct SelectorCellModel {
    var icon: UIImage
    var topText: String
    var bottomText: String
    var type: SelectorItemsType
}

protocol SelectorItemsType {
    var rawValue: Int { get }
}

enum MuteType: Int, SelectorItemsType {
    case unknown = -1
    case unmuted = 0
    case muted = 1
    
    static func type(from bool: Bool?) -> MuteType {
        guard let bool = bool else { return .unknown }
        
        return bool == false ? .unmuted : .muted
    }
}

enum TeamNotificationsType: Int, SelectorItemsType, Codable {
    case never = 0
    case often = 1
    case occasionally = 2
    case rarely = 3
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = TeamNotificationsType(rawValue: value) ?? .never
    }
    
    func encode(to encoder: Encoder) throws {
        let intValue = self.rawValue
        var container = encoder.singleValueContainer()
        try container.encode(intValue)
    }
    
}

enum PinType: Int, SelectorItemsType, Decodable {
    case unpinned = -1
    case unknown = 0
    case pinned = 1
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = PinType(rawValue: value) ?? .unknown
    }
}

struct SettingsEntity: Codable {
    let type: TeamNotificationsType
    let teamID: Int?
    
    enum CodingKeys: String, CodingKey {
        case type = "NewTeammatesNotification"
        case teamID = "TeamId"
    }
}
