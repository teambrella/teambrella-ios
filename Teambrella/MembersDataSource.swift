//
//  MembersDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

class MembersDatasource {
    enum TeammateSectionType {
        case new, teammate
    }
    
    var newTeammates: [TeammateLike] = []
    var teammates: [TeammateLike] = []
    var onUpdate: (() -> Void)?
    
    var sections: Int {
        var count = 2
        if newTeammates.isEmpty { count -= 1 }
        if teammates.isEmpty { count -= 1 }
        return count
    }
    
    func type(indexPath: IndexPath) -> TeammateSectionType {
        switch indexPath.section {
        case 0:
            return newTeammates.isEmpty ? .teammate : .new
        default:
            return .teammate
        }
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
    
    func headerTitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "NEW TEAMMATES"
        case .teammate:
            return "TEAMMATES"
        }
    }
    
    func headerSubtitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "VOTING ENDS IN"
        case .teammate:
            return "NET"
        }
    }
    
    func loadData() {
        fakeLoadData()
    }
    
    subscript(indexPath: IndexPath) -> TeammateLike {
        switch type(indexPath: indexPath) {
        case .new:
            return newTeammates[indexPath.row]
        case .teammate:
            return teammates[indexPath.row]
        }
    }
    
    func fakeLoadData() {
        for i in 0...20 {
            let teammate = FakeTeammate(json: JSON(""))
            if teammate.isJoining {
                newTeammates.append(teammate)
            } else {
                teammates.append(teammate)
            }
        }
        onUpdate?()
    }
    
}

final class FakeTeammate: TeammateLike {
    var ver: Int64 = 0
    let id: String = "666"
    
    let claimLimit: Int = 0
    let claimsCount: Int = 0
    let isJoining: Bool = Random.bool
    let isVoting: Bool = false
    let model: String = "Fake"
    let name: String = "Fake"
    let risk: Double = 0
    let riskVoted: Double = 0
    let totallyPaid: Double = 0
    let hasUnread: Bool = Random.bool
    let userID: String = "666"
    let year: Int = 0
    let avatar: String = ""
    
    var extended: ExtendedTeammate?
    
    var description: String {
        return "Fake Teammate"
    }
    
    var isComplete: Bool { return extended != nil }
    
    init(json: JSON) {
    }
}
