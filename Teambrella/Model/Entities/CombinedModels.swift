//
//  CombinedModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
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
//

import Foundation

struct TeamsModel: Decodable, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case teams = "MyTeams"
        case invitations = "MyInvitations"
        case lastTeamID = "LastSelectedTeam"
        case userID = "UserId"
    }
    
    let teams: [TeamEntity]
    let invitations: [InviteToTeamEntity]
    let lastTeamID: Int?
    let userID: String
    
    var description: String {
        return """
        TeamsModel: teams \(teams.count), invitations: \(invitations.count), \
        lastID: \(String(describing: lastTeamID)), userID: \(userID)
        """
    }
    
}

protocol ReportModel {
    var teamID: Int { get }
    var text: String { get }
    
    var isValid: Bool { get }
}

struct NewClaimModel: ReportModel {
    let teamID: Int
    let incidentDate: Date
    let expenses: Double
    let text: String
    let images: [String]
    let address: String

    let coverage: Coverage
    
    var isValid: Bool { return coverage.value > 0 && expenses > 0 && text.count >= 30 && address != "" }
}

struct NewChatModel: ReportModel {
    let teamID: Int
    let title: String
    let text: String
    
    var isValid: Bool { return title != "" && text.count >= 30 }
}
