//
//  ClaimsDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.

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
    
    lazy var claims: [[ClaimEntity]] = {
        var array: [[ClaimEntity]] = []
        for _ in self.order {
            var subArray: [ClaimEntity] = []
            array.append(subArray)
        }
        return array
    }()
    
    // if teammate id is set all results will be filtered
    var teammateID: String?
    
    var homeModel: HomeScreenModel?
    
    var claimItem: ClaimItem? {
        guard let model = homeModel else { return nil }
        
        return ClaimItem(name: model.objectName, photo: model.smallPhoto, location: "")
    }
    
    var reportContext: ReportContext? {
        guard let item = claimItem,
            let coverage = homeModel?.coverage,
            let balance = homeModel?.balance else { return nil }
        
        return ReportContext.claim(item: item, coverage: coverage, balance: balance)
    }
    
    var unreadCount: Int { return homeModel?.unreadCount ?? 0 }
    
    private var order: [ClaimsCellType] = [.open,
                                           .voted,
                                           .paid,
                                           .fullyPaid]
    
    var count: Int { return claims.flatMap { $0 }.count }
    // swiftlint:disable:next empty_count
    var isEmpty: Bool { return count == 0 }
    
    var sections: Int { return claims.count }
    var offset = 0
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadHome: (() -> Void)?
    
    var isSilentUpdate = false
    
    func loadData() {
        let offset = isSilentUpdate ? 0 : count
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
            
            var payload: [String: Any] = ["TeamId": service.session?.currentTeam?.teamID ?? 0,
                                          "Offset": offset,
                                          "Limit": Constant.loadLimit,
                                          "AvatarSize": Constant.avatarSize]
            if let teammateID = self.teammateID {
                payload["TeammateIdFilter"] = teammateID
            }
            let body = RequestBody(key: key, payload: payload)
            let request = TeambrellaRequest(type: .claimsList, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                if case .claimsList(let claims) = response {
                    if self.isSilentUpdate {
                        for idx in 0..<self.claims.count {
                            self.claims[idx].removeAll()
                        }
                        self.isSilentUpdate = false
                    }
                    self.offset += claims.count
                    
                    self.process(claims: claims)
                    self.onUpdate?()
                    self.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
        
    }
    
    func loadHomeData() {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        
        service.dao.requestHome(teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(model):
                self?.homeModel = model
                self?.onLoadHome?()
            case let .temporaryValue(model):
                self?.homeModel = model
                self?.onLoadHome?()
            case let .error(error):
                log("\(error)", type: .error)
            }
        }
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
    
    func headerText(for indexPath: IndexPath) -> String {
        switch cellType(for: indexPath) {
        case .fullyPaid: return "Team.Claims.State.Header.fullyPaid".localized
        case .open: return ""
        case .paid: return "Team.Claims.State.Header.beingPaid".localized
        case .voted: return "Team.Claims.State.Header.voted".localized
        }
    }
    
    func showHeader(for section: Int) -> Bool {
        return claims[section].isEmpty == false
    }
    
    private func process(claims: [ClaimEntity]) {
        for claim in claims {
            let idx: Int!
            switch claim.state {
            case .voting, .revoting: idx = 0
            case .voted: idx             = 1
            case .inPayment: idx         = 2
            default: idx                 = 3
            }
            self.claims[idx].append(claim)
        }
    }
    
    func itemsInSection(section: Int) -> Int { return self.claims[section].count }
    
    func cellType(for indexPath: IndexPath) -> ClaimsCellType {
        return order[indexPath.section]
    }
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return order[indexPath.section].identifier
    }
    
    func cellsIn(section: Int) -> Int {
        return claims[section].count
    }
    
    subscript(indexPath: IndexPath) -> ClaimEntity {
        return claims[indexPath.section][indexPath.row]
    }
}
