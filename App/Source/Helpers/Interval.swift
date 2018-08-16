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

struct Interval {
    let start: Date
    let end: Date

    var interval: Int {
        return Int(end.timeIntervalSince(start))
    }

    var seconds: Int {
        return interval % 60
    }

    var minutes: Int {
        return interval / 60 % 60
    }

    var hours: Int {
        return interval / 3600 % 24
    }

    var formattedString: String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
