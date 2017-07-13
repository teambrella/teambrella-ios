//
//  ValueToTextConverter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
        guard amount.truncatingRemainder(dividingBy: 1) > 0.01 else { return "\(Int(amount))" }
        
        return String(format: "%.2f", amount)
    }
}
