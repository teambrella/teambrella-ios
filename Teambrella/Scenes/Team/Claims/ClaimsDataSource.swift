//
//  ClaimsDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class ClaimsDataSource {
    struct Constant {
        static let loadLimit = 10
        static let avatarSize = 128
    }
    
    enum ClaimsCellType {
        case open
        case voted
        case paid
        case fullyPaid
        
        var identifier: String {
            switch self {
            case .open: return "ClaimsOpenCell"
            case .voted: return "ClaimsVotedCell"
            case .paid: return "ClaimsPaidCell"
            case .fullyPaid: return "ClaimsPaidCell"
            }
        }
    }
    
    lazy var claims: [[ClaimLike]] = {
        var array: [[ClaimLike]] = []
        for _ in self.order {
            var subArray: [ClaimLike] = []
            array.append(subArray)
        }
        return array
    }()
    
    // if teammate is set all results will be filtered
    var teammate: TeammateLike?
    private var order: [ClaimsCellType] = [.open,
                                   .voted,
                                   .paid,
                                   .fullyPaid]
    
    var count: Int { return claims.flatMap { $0 }.count }
    var sections: Int { return claims.count }
    var offset = 0
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.Constant.teamID,
                                                      "Offset": self.offset,
                                                      "Limit": Constant.loadLimit,
                                                      "AvatarSize": Constant.avatarSize])
            let request = TeambrellaRequest(type: .claimsList, body: body, success: { [weak self] response in
                if case .claimsList(let claims) = response {
                    guard let me = self else { return }
                    
                    me.offset += claims.count
                    
                    me.process(claims: claims)
                    me.onUpdate?()
                    me.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
        
    }
    
    private func process(claims: [ClaimLike]) {
        for claim in claims {
            let idx: Int!
            switch claim.state {
            case .voting, .revoting: idx = 0
            case .voted: idx = 1
            case .inPayment: idx = 2
            default: idx = 3
            }
            self.claims[idx].append(claim)
        }
    }
    
    func cellType(for indexPath: IndexPath) -> ClaimsCellType {
        return order[indexPath.section]
    }
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return order[indexPath.section].identifier
    }
    
    func cellsIn(section: Int) -> Int {
        return claims[section].count
    }
    
    subscript(indexPath: IndexPath) -> ClaimLike {
        return claims[indexPath.section][indexPath.row]
    }
}
