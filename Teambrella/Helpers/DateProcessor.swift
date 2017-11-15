//
//  DateProcessor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.07.17.

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
import SwiftDate

struct DateProcessor {
    
    // swiftlint:disable force_try
    func stringInterval(from date: Date, isColloquial: Bool = true) -> String {
        let (colloquial, relevant) = try! date.colloquial(to: Date())
        return isColloquial ? colloquial : relevant ?? ""
    }
    
    // swiftlint:disable force_try
    func stringFromNow(seconds: Int = 0,
                       minutes: Int = 0,
                       hours: Int = 0,
                       days: Int = 0,
                       isColloquial: Bool = true) -> String {
        let seconds = seconds + minutes * 60 + hours * 3600 + days * 3600 * 24
        let fullDays = abs(seconds / 60 / 60 / 24)
        let fullHours = abs(seconds / 3600)
        let fullMinutes = abs(seconds / 60)
        if fullDays > 0 {
            return "Team.Members.days_format".localized(fullDays)
        } else if fullHours > 0 {
            return "Team.Members.hours_format".localized(fullHours)
        } else if fullMinutes > 0 {
            return "Team.Members.minutes_format".localized(fullMinutes)
        } else {
            // fall back to previous implementation
            let dateInRegion: DateInRegion = DateInRegion()
            let date = dateInRegion - days.days - hours.hours - minutes.minutes - seconds.seconds
            let (colloquial, relevant) = try! date.colloquialSinceNow()
            return isColloquial ? colloquial : relevant ?? ""
        }
    }
    
    func stringIntervalOrDate(from date: Date) -> String {
        let days = Date().interval(of: .day, since: date)
        if  days >= 7 {
            let formatter = DateFormatter()
            let locale = Locale.current
            formatter.locale = locale
            formatter.dateStyle = .short
            return formatter.string(from: date)
        } else if days <= 1 {
            return "General.today".localized.capitalized
        } else {
            return stringInterval(from: date)
        }
    }
}
