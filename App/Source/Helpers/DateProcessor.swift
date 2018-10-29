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

import ExtensionsPack
import Foundation
import SwiftDate

struct DateProcessor {
    func stringInterval(from date: Date) -> String {
        let interval = Date() - date
        if let years = interval.year, years > 0 { return "" }

        let days = interval.day ?? 0
        let months = interval.month ?? 0
        let daysTotal = months * 30 + days
        return stringFromNow(seconds: interval.second ?? 0,
                             minutes: interval.minute ?? 0,
                             hours: interval.hour ?? 0,
                             days: daysTotal)
    }

    func stringFromNow(seconds: Int = 0,
                       minutes: Int = 0,
                       hours: Int = 0,
                       days: Int = 0) -> String {
        let seconds = seconds + minutes * 60 + hours * 3600 + days * 3600 * 24
        let fullDays = abs(seconds / 60 / 60 / 24)
        let fullHours = abs(seconds / 3600)
        let fullMinutes = abs(seconds / 60)
        if fullDays > 30 {
            return "General.longAgo".localized
        } else if fullDays > 0 {
            return "Team.Members.days_format".localized(fullDays)
        } else if fullHours > 0 {
            return "Team.Members.hours_format".localized(fullHours)
        } else if fullMinutes > 0 {
            return "Team.Members.minutes_format".localized(fullMinutes)
        } else {
            return ""
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
        } else if days < 1 {
            return "General.today".localized.capitalized
        } else {
            return stringInterval(from: date)
        }
    }
    
    func yearFilter(from date: Date) -> String {
        let modelYear = NSCalendar.current.component(.year, from: date)
        let currentDate = Date()
        let currentYear = NSCalendar.current.component(.year, from: currentDate)
        
        let dateFormatter = DateFormatter()
        let template = modelYear == currentYear ? "dMMMM" : "YYYYdMMM"
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template,
                                                            options: 0,
                                                            locale: NSLocale.current)
        return dateFormatter.string(from: date)
    }
    
    func stringAgo(passedMinutes: Int) -> String {
        var agoText = ""
        switch passedMinutes {
        case 0:
            agoText = "Team.TeammateCell.timeLabel.justNow".localized
        case 1..<60:
            agoText = "Team.Ago.minutes_format".localized(passedMinutes)
        case 60..<(60 * 24):
            agoText = "Team.Ago.hours_format".localized(passedMinutes / 60)
        case 1440...10080: //(60 * 24)...(60 * 24 * 7):
            agoText = "Team.Ago.days_format".localized(passedMinutes / (60 * 24))
        default:
            let date = Date().addingTimeInterval(TimeInterval(-passedMinutes * 60))
            agoText = DateProcessor().yearFilter(from: date)
        }
        return agoText
    }
    
    func stringFinishesIn(minutesRemaining: Int) -> String {
        var prefix = ""
        if minutesRemaining < 60 {
            prefix = "Team.Claim.minutes_format".localized(minutesRemaining)
        } else if minutesRemaining < 60 * 24 {
            prefix = "Team.Claim.hours_format".localized(minutesRemaining / 60)
        } else {
            prefix = "Team.Claim.days_format".localized(minutesRemaining / (60 * 24))
        }
        return prefix.uppercased() + " " + DateProcessor().stringFromNow(minutes: -minutesRemaining).uppercased()
    }
}
