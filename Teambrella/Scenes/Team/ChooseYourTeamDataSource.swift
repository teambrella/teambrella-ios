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
    var models: [TeamCellModel] = []
    var currentTeamIndex: Int {
        if let currentTeam = service.session?.currentTeam, let idx = service.session?.teams.index(of: currentTeam) {
            return idx
        }
        return 0
    }
    
    mutating func createModels() {
        guard let teams = service.session?.teams else { return }
        
        for team in teams {
            models.append(ChooseYourTeamCellModel(team: team))
        }
        models.append(SwitchUserTeamCellModel())
    }
    
    subscript(indexPath: IndexPath) -> TeamCellModel {
        return models[indexPath.row]
    }
    
}
