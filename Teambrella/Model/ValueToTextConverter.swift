//
//  ValueToTextConverter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

struct ValueToTextConverter {
    static func decisionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<30: return "Team.Decisions.generous".localized
        case 30..<45: return "Team.Decisions.mild".localized
        case 45..<55: return "Team.Decisions.moderate".localized
        case 55..<70: return "Team.Decisions.severe".localized
        case 70...100: return "Team.Decisions.harsh".localized
        default: return "Team.unknown".localized
        }
    }
    
    static func discussionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<3: return "Team.Discussions.quiet".localized
        case 3..<10: return "Team.Discussions.reserved".localized
        case 10..<25: return "Team.Discussions.moderate".localized
        case 25..<50: return "Team.Discussions.sociable".localized
        case 50...100: return "Team.Discussions.chatty".localized
        default: return "Team.unknown".localized
        }
    }
    
    static func frequencyText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0: return "Team.Frequency.never".localized
        case 1..<5: return "Team.Frequency.rarely".localized
        case 5..<15: return "Team.Frequency.occasionally".localized
        case 15..<30: return "Team.Frequency.frequently".localized
        case 30..<60: return "Team.Frequency.often".localized
        case 60..<95: return "Team.Frequency.regularly".localized
        case 95...100: return "Team.Frequency.always".localized
        default: return "Team.unknown".localized
        }
    }
    
    static func textFor(amount: Double?) -> String {
        guard let amount = amount else { return "..." }
        guard amount >= 100 else { return String.formattedNumber(amount) }
        
        return String.truncatedNumber(amount)
    }
}
