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
    var onError: ((Error) -> Void)?
    var sortType: SortVC.SortType = .none
    
    var offset = 0
    var isLoading = false
    
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
        onUpdate?()
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
    
    func loadData() {
        //fakeLoadData()
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.teamID,
                                                      "Offset": self.offset,
                                                      "Limit": 10,
                                                      "AvatarSize": 128])
            let request = TeambrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
                if case .teammatesList(let teammates) = response {
                    guard let me = self else { return }
                    
                    for teammate in teammates {
                        switch teammate.isJoining {
                        case true:
                            me.newTeammates.append(teammate)
                        case false:
                            me.teammates.append(teammate)
                        }
                    }
                    me.offset += teammates.count
                    me.onUpdate?()
                    me.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
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
    
    func fakeLoadData() {
        for _ in 0...20 {
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
    func updateWithVote(json: JSON) {
        
    }

    var lastUpdated: Int64 = 0
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
    let avatar: String = "http://beauty-around.com/images/sampledata/SWEDEN_Women/15.jpg"
    
    var extended: ExtendedTeammate?
    
    var description: String {
        return "Fake Teammate"
    }
    
    var isComplete: Bool { return extended != nil }
    
    init(json: JSON) {
    }
    
}
