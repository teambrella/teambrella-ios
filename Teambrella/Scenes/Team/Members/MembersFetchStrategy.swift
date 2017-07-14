//
//  MembersFetchStrategy.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol MembersFetchStrategy {
    var sections: Int { get }
    var sortType: SortVC.SortType { get }
    var ranges: [RiskScaleEntity.Range] { get set }
    
    func type(indexPath: IndexPath) -> TeammateSectionType
    func itemsInSection(section: Int) -> Int
    func headerTitle(indexPath: IndexPath) -> String
    func headerSubtitle(indexPath: IndexPath) -> String
    func arrange(teammates: [TeammateLike])
    func sort(type: SortVC.SortType)
    
    subscript(indexPath: IndexPath) -> TeammateLike { get }
}

class MembersListStrategy: MembersFetchStrategy {
    var ranges: [RiskScaleEntity.Range] = []
    var newTeammates: [TeammateLike] = []
    var teammates: [TeammateLike] = []
    var sortType: SortVC.SortType = .none
    
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
    
    func arrange(teammates: [TeammateLike]) {
        for teammate in teammates {
            switch teammate.isJoining {
            case true:
                newTeammates.append(teammate)
            case false:
                self.teammates.append(teammate)
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> TeammateLike {
        switch type(indexPath: indexPath) {
        case .new:
            return newTeammates[indexPath.row]
        case .teammate:
            return teammates[indexPath.row]
        }
    }
    
}

class MembersRiskStrategy: MembersFetchStrategy {
    var arrayOfRanges: [[TeammateLike]] = []
    var ranges: [RiskScaleEntity.Range] = []
    var sections: Int { return arrayOfRanges.count }
    var sortType: SortVC.SortType = .none
    
    func type(indexPath: IndexPath) -> TeammateSectionType {
        return .teammate
    }
    
    func itemsInSection(section: Int) -> Int {
        return arrayOfRanges[section].count
    }
    
    func headerTitle(indexPath: IndexPath) -> String {
        return "Team.Members.Teammates.Strategy.headerTitle".localized(ranges[indexPath.section].left,
                                                                       ranges[indexPath.section].right)
    }
    
    func headerSubtitle(indexPath: IndexPath) -> String {
        return "Team.Members.Teammates.Strategy.headerSubtitle".localized
    }
    
    func arrange(teammates: [TeammateLike]) {
        if arrayOfRanges.isEmpty {
            for _ in ranges {
                arrayOfRanges.append([TeammateLike]())
            }
        }
        
        for (idx, range) in ranges.enumerated() {
            for teammate in teammates {
                if teammate.risk >= range.left && teammate.risk <= range.right {
                    arrayOfRanges[idx].append(teammate)
                }
            }
        }
       // print("ranges: \(arrayOfRanges.count), items: \(arrayOfRanges.flatMap { $0 }.count)")
    }
    
    func sort(type: SortVC.SortType) {
        
    }
    
    subscript(indexPath: IndexPath) -> TeammateLike {
        return arrayOfRanges[indexPath.section][indexPath.row]
    }
}
