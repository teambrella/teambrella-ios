//
//  MembersFetchStrategy.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.07.17.

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

protocol MembersFetchStrategy {
    var sections: Int { get }
    var sortType: SortVC.SortType { get }
    var ranges: [RiskScaleRange] { get set }
    var items: [[TeammateListEntity]] { get }
    
    func type(indexPath: IndexPath) -> TeammateSectionType
    func itemsInSection(section: Int) -> Int
    func headerTitle(indexPath: IndexPath) -> String
    func headerSubtitle(indexPath: IndexPath) -> String
    func arrange(teammates: [TeammateListEntity])
    func sort(type: SortVC.SortType)
    func removeData()
    
    subscript(indexPath: IndexPath) -> TeammateListEntity { get }
}

class MembersListStrategy: MembersFetchStrategy {
    var ranges: [RiskScaleRange] = []
    var newTeammates: [TeammateListEntity] = []
    var teammates: [TeammateListEntity] = []
    var sortType: SortVC.SortType = .none
    var items: [[TeammateListEntity]] { return [newTeammates, teammates] }
    func removeData() {
        teammates.removeAll()
        newTeammates.removeAll()
    }
    
    var sections: Int {
        var count = 2
        if newTeammates.isEmpty { count -= 1 }
        if teammates.isEmpty { count -= 1 }
        return count
    }
    
    func itemsInSection(section: Int) -> Int {
        switch section {
        case 0:
            return newTeammates.isEmpty ? teammates.count : newTeammates.count
        case 1:
            return teammates.count
        default:
            break
        }
        return 0
    }
    
    func type(indexPath: IndexPath) -> TeammateSectionType {
        switch indexPath.section {
        case 0:
            return newTeammates.isEmpty ? .teammate : .new
        default:
            return .teammate
        }
    }
    
    func sort(type: SortVC.SortType) {
        switch type {
        case .alphabeticalAtoZ:
            newTeammates.sort { $0.name < $1.name }
            teammates.sort { $0.name < $1.name }
        case .alphabeticalZtoA:
            newTeammates.sort { $0.name > $1.name }
            teammates.sort { $0.name > $1.name }
        default:
            break
        }
        sortType = type
    }
    
    func headerTitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "Team.Teammates.newTeammates".localized
        case .teammate:
            return "Team.Teammates.teammates".localized
        }
    }
    
    func headerSubtitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "Team.Teammates.votingEndsIn".localized
        case .teammate:
            return "Team.Teammates.net".localized
        }
    }
    
    func arrange(teammates: [TeammateListEntity]) {
        for teammate in teammates {
            if teammate.isVoting || teammate.isJoining {
                newTeammates.append(teammate)
            } else {
                self.teammates.append(teammate)
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> TeammateListEntity {
        switch type(indexPath: indexPath) {
        case .new:
            return newTeammates[indexPath.row]
        case .teammate:
            return teammates[indexPath.row]
        }
    }
    
}

class MembersRiskStrategy: MembersFetchStrategy {
    var items: [[TeammateListEntity]] = []
    var ranges: [RiskScaleRange] = []
    var sections: Int { return items.count }
    var sortType: SortVC.SortType = .none
    
    func removeData() {
        items.removeAll()
    }
    
    func type(indexPath: IndexPath) -> TeammateSectionType {
        return .teammate
    }
    
    func itemsInSection(section: Int) -> Int {
        return items[section].count
    }
    
    func headerTitle(indexPath: IndexPath) -> String {
        return "Team.Members.Teammates.Strategy.headerTitle".localized(ranges[indexPath.section].left,
                                                                       ranges[indexPath.section].right)
    }
    
    func headerSubtitle(indexPath: IndexPath) -> String {
        return "Team.Members.Teammates.Strategy.headerSubtitle".localized
    }
    
    func arrange(teammates: [TeammateListEntity]) {
        if items.isEmpty {
            for _ in ranges {
                items.append([TeammateListEntity]())
            }
        }
        
        for (idx, range) in ranges.enumerated() {
            for teammate in teammates {
                let risk = teammate.risk ?? 0
                if risk >= range.left && risk <= range.right {
                    items[idx].append(teammate)
                }
            }
        }
       // print("ranges: \(arrayOfRanges.count), items: \(arrayOfRanges.flatMap { $0 }.count)")
    }
    
    func sort(type: SortVC.SortType) {
        
    }
    
    subscript(indexPath: IndexPath) -> TeammateListEntity {
        return items[indexPath.section][indexPath.row]
    }
}
