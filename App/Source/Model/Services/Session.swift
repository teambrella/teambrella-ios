//
//  Session.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.06.17.

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
import UXCam

class Session {
    var isDemo: Bool

    var currentTeam: TeamEntity?
    var teams: [TeamEntity] = []
    
    // TMP: my user properties
    var currentUserID: String
    var currentUserTeammateID: Int? { return currentTeam?.teammateID }
    var currentUserName: Name?
    var currentUserAvatar: Avatar = Avatar.none
    var currentUserEthereumAddress: String? {
        return service.teambrella.processor.ethAddressString
    }
    
    var cryptoCurrency: Ether = Ether.empty
    var cryptoCoin: MEth = MEth(0)

    //var coinName: String { return cryptoCurrency.child?.code ?? "" }
    
    var myAvatarString: String { return "me/avatar" }
    var myAvatarStringSmall: String { return myAvatarString + "/128" }
    var dataSource: HomeDataSource = HomeDataSource()
    
    init(teamsModel: TeamsModel, isDemo: Bool) {
        self.currentUserID = teamsModel.userID
        self.isDemo = isDemo
        self.teams = teamsModel.teams
        /*
         Selecting team that was used last time

         Firstly we try to use teamID that comes from server (but it is not implemented yet)
         Secondly we use a stored on device last used teamID
         and lastly if everything fails we take the first team from the list
         */
        let lastTeamID: Int
        if let receivedID = teamsModel.lastTeamID {
            lastTeamID = receivedID
        } else if let storedID = SimpleStorage().int(forKey: .teamID) {
            lastTeamID = storedID
        } else {
            lastTeamID = teamsModel.teams.first?.teamID ?? 0
        }
        var currentTeam: TeamEntity?
        for team in teamsModel.teams where team.teamID == lastTeamID {
            currentTeam = team
            break
        }
        self.currentTeam = currentTeam ?? teams.first
        SimpleStorage().store(bool: false, forKey: .isRegistering)
    }
    
    @discardableResult
    func switchToTeam(id: Int) -> Bool {
        guard let currentTeam = currentTeam, currentTeam.teamID != id else { return false }
        
        SimpleStorage().store(int: id, forKey: .teamID)
        
        let filtered = teams.filter { $0.teamID == id }
        if let team = filtered.first {
            self.currentTeam = team
            return true
        }
        return false
    }
}

extension Session {
    func updateMyUser(with model: HomeModel?) {
        guard let model = model else { return }
        
        currentUserID = model.userID
        currentUserName = model.name
        currentUserAvatar = model.avatar
        
        // Lets UXCam know the name of the person whose screen is being inspected
        UXCam.setUserIdentity(model.name.entire)
    }
}
