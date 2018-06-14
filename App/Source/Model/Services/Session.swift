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

class Session {
    var isDemo: Bool
    
    var currentTeam: TeamEntity?
    var teams: [TeamEntity] = []
    
    // TMP: my user properties
    var currentUserID: String?
    var currentUserTeammateID: Int? { return currentTeam?.teammateID }
    var currentUserName: Name?
    var currentUserAvatar: Avatar = Avatar.none
    
    var cryptoCurrency: Ether = Ether.empty
    var cryptoCoin: MEth = MEth(0)

    //var coinName: String { return cryptoCurrency.child?.code ?? "" }
    
    var myAvatarString: String { return "me/avatar" }
    var myAvatarStringSmall: String { return myAvatarString + "/128" }
    var dataSource: HomeDataSource = HomeDataSource()
    
    init(isDemo: Bool) {
        self.isDemo = isDemo
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
