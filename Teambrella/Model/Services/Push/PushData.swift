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

struct PushData {
    let dict: [AnyHashable: Any]
    var aps: [String: Any] { return dict["aps"] as? [String : Any] ?? [:] }
    var body: String? { return (aps["alert"] as? [String: String])?["body"] }
    var title: String? { return (aps["alert"] as? [String: String])?["title"] }
    var badge: Int { return aps["badge"] as? Int ?? 0 }
    var isContentAvailable: Bool { return aps["content-available"] as? Bool ?? false }
    var command: PushCommand? { return PushCommand.with(dict: dict["cmd"] as? [String: Any]) }
}
