//
//  TeammateProfileDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.

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

import UIKit

enum TeammateProfileCellType: String {
    case me, summary, object, stats, contact, dialog, dialogCompact, voting, voted
}

enum SocialItemType: String {
    case facebook, twitter, email, call
}

struct SocialItem {
    var name: String {
        return type.rawValue
    }
    let type: SocialItemType
    let icon: UIImage?
    let address: String
}

class TeammateProfileDataSource {
    let teammateID: String
    let teamID: Int
    let isMe: Bool
    // let isVoting: Bool
    var isMyProxy: Bool {
        get {
            return teammateLarge?.basic.isMyProxy ?? false
        }
        set {
            teammateLarge?.myProxy(set: newValue)
        }
    }
    
    var source: [TeammateProfileCellType] = []
    var teammateLarge: TeammateLarge?
    var riskScale: RiskScaleEntity? { return teammateLarge?.riskScale }
    var isNewTeammate = false
    
    var votingCellIndexPath: IndexPath? {
        for (idx, cellType) in source.enumerated() where cellType == .voting {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }
    
    init(id: String, teamID: Int, isMe: Bool) {
        self.teammateID = id
        self.isMe = isMe
        self.teamID = teamID
    }
    
    var sections: Int = 1
    
    func rows(in section: Int) -> Int {
        return source.count
    }
    
    func type(for indexPath: IndexPath) -> TeammateProfileCellType {
        return source[indexPath.row]
    }
    
    func loadEntireTeammate(completion: @escaping (TeammateLarge) -> Void,
                            failure: @escaping (Error) -> Void) {
        service.dao.requestTeammate(userID: teammateID, teamID: teamID).observe { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case let .value(teammate):
                self.teammateLarge = teammate
                self.modifySource()
                completion(teammate)
            case let .error(error):
                failure(error)
            }
        }
    }
    
    func addToProxy(completion: @escaping () -> Void) {
        service.dao.myProxy(userID: teammateID, add: !isMyProxy).observe { [weak self] result in
            switch result {
            case .value:
                guard let me = self else { return }
                
                me.isMyProxy = !me.isMyProxy
                completion()
            case let .error(error):
                log("\(#file) \(error)", type: .error)
                completion()
            }
        }
    }
    
    func sendRisk(userID: Int, risk: Double?, completion: @escaping (TeammateVotingResult) -> Void) {
        service.dao.sendRiskVote(teammateID: userID, risk: risk).observe { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case let .value(votingResult):
                self.teammateLarge?.update(votingResult: votingResult)
                completion(votingResult)
            case let .error(error):
                log("\(#file) \(error)", type: .error)
            }
        }
    }
    
    private func modifySource() {
        guard let teammate = teammateLarge else { return }
        
        source.removeAll()
        isMyProxy = teammate.basic.isMyProxy
        let isVoting = teammate.voting != nil
        
        //if isMe { source.append(.me) } else { source.append(.summary) }
        source.append(.dialog)
        if isVoting {
            isNewTeammate = true
            //source.append(.dialogCompact)
            source.append(.voting)
        }
        source.append(.object)
        source.append(.stats)
        if !socialItems.isEmpty && !isMe {
            source.append(.contact)
        }
    }
    
    var socialItems: [SocialItem] {
        var items: [SocialItem] = []
        if let facebook = teammateLarge?.basic.facebook {
            items.append(SocialItem(type: .facebook, icon: #imageLiteral(resourceName: "facebook"), address: facebook))
        }
        if isMyProxy {
            items.append(SocialItem(type: .call, icon: #imageLiteral(resourceName: "call"), address: ""))
        }
        return items
    }
}
