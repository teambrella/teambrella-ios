//
//  ChooseYourTeamDataSource.swift
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

struct ChooseYourTeamDataSource {
    var count: Int { return models.count }
    var models: [ChooseYourTeamCellModel] = []
    var currentTeamIndex: Int {
        if let currentTeam = service.session?.currentTeam, let idx = service.session?.teams.index(of: currentTeam) {
            return idx
        }
        return 0
    }
    
    mutating func createModels() {
        guard let model = service.session?.teams else { return }
        
        for card in model {
            if let inc = card.unreadCount, let item = card.objectName, let cvg = card.teamCoverage {
                models.append(ChooseYourTeamCellModel(teamIcon: card.teamLogo,
                                                      incomingCount: inc,
                                                      teamName: card.teamName,
                                                      itemName: item,
                                                      coverage: Int(cvg),
                                                      teamID: card.teamID))
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> ChooseYourTeamCellModel {
        return models[indexPath.row]
    }
    
}
