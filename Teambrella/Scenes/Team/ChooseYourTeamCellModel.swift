//
//  ChooseYourTeamCellModel.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.

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

protocol TeamCellModel {
    
}

struct ChooseYourTeamCellModel: TeamCellModel {
    var teamIcon: String
    var incomingCount: String
    var teamName: String
    var itemName: String
    var coverage: String
    var teamID: Int
    
    init(team: TeamEntity) {
        teamIcon = team.teamLogo
        if let unreadCount = team.unreadCount, unreadCount > 0 {
            incomingCount = "\(unreadCount)"
        } else {
            incomingCount = ""
        }
        teamName = team.teamName
        itemName = team.objectName ?? ""
        if let coverage = team.objectCoverage {
            self.coverage = String.formattedNumber(coverage * 100) + "%"
        } else {
            self.coverage = "0%"
        }
        teamID = team.teamID
    }
}

struct SwitchUserTeamCellModel: TeamCellModel {
    let name = "Team.ChooseTeam.switchUser".localized
}
