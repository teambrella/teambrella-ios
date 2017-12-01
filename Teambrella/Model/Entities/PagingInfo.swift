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

/**
    Used in feed/getList reply to manage pagination with chunks
 */
struct PagingInfo {
    let lastItemIndex: Int64
    let limit: Int
    let size: Int
    
    init?(json: JSON?) {
        guard let json = json else { return nil }
        guard let lastItemIndex = json["LastItemIndex"].int64,
        let limit = json["Limit"].int,
            let size = json["Size"].int else { return nil }
        
        self.lastItemIndex = lastItemIndex
        self.limit = limit
        self.size = size
    }
    
}
