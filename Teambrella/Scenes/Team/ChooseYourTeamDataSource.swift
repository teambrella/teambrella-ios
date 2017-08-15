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
    
    mutating func createModels() {
        let model = service.session.teams
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
    
    // swiftlint:disable:next function_body_length
    mutating func createFakeModels() {
        models = [ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 12,
                                          teamName: "Deductable Savers",
                                          itemName: "Mazda CX5",
                                          coverage: 95,
                                          teamID: 0),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 3,
                                          teamName: "Animal Protection",
                                          itemName: "BENGAaaaaaaaa CATS",
                                          coverage: 100,
                                          teamID: 1),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 0,
                                          teamName: "Dogs",
                                          itemName: "Mazda CX5",
                                          coverage: 30,
                                          teamID: 2),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 12,
                                          teamName: "Cats",
                                          itemName: "Mazda CX5",
                                          coverage: 40,
                                          teamID: 3),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 15,
                                          teamName: "Cars",
                                          itemName: "Mazda CX5",
                                          coverage: 70,
                                          teamID: 4),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 1,
                                          teamName: "Trolleybuses detectedddd",
                                          itemName: "Mazda CX5",
                                          coverage: 80,
                                          teamID: 5),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 7,
                                          teamName: "Deductable Savers",
                                          itemName: "Mazda CX5",
                                          coverage: 20,
                                          teamID: 6),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 123,
                                          teamName: "Washmachines",
                                          itemName: "Mazda CX5",
                                          coverage: 50,
                                          teamID: 7),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 0,
                                          teamName: "Refregerators",
                                          itemName: "Mazda CX5",
                                          coverage: 60,
                                          teamID: 8),
                  ChooseYourTeamCellModel(teamIcon: " ",
                                          incomingCount: 5,
                                          teamName: "Insurance",
                                          itemName: "Mazda CX5",
                                          coverage: 10,
                                          teamID: 9)]
    }
    
    subscript(indexPath: IndexPath) -> ChooseYourTeamCellModel {
        return models[indexPath.row]
    }
    
}
