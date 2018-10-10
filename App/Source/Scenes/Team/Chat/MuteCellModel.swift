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

struct MuteCellModel {
    var icon: UIImage
    var topText: String
    var bottomText: String
    var type: MuteType
}

protocol MuteType {
    var rawValue: Int { get }
}

enum ChatMuteType: Int, MuteType {
    case unknown = -1
    case unmuted = 0
    case muted = 1
    
    static func type(from bool: Bool?) -> ChatMuteType {
        guard let bool = bool else { return .unknown }
        
        return bool == false ? .unmuted : .muted
    }
}

enum NotificationsMuteType: Int, MuteType {
    case never = 0
    case often = 1
    case occasionally = 2
    case rarely = 3
}
