//
//  Date.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.05.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

extension Date {
    func interval(of component: Calendar.Component, since date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: component, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: component, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    var cSharpString: String { return iso8601 }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    // C# timestamp format
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    init(ticks: UInt64) {
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
}
