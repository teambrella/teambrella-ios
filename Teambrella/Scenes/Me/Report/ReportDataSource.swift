//
//  ReportDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.06.17.

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

class ReportDataSource {
    enum ReportCellType {
        case item
        case date
        case expenses
        case description
        case photos
        case wallet
    }
    
    let context: ReportContext
    var items: [ReportCellModel] = []
    var count: Int { return items.count }
    var coverage: Coverage = Coverage.no
    var limit: Double = 0
    
    var onUpdateCoverage: (() -> Void)?
    
    init(context: ReportContext) {
        self.context = context
        switch context {
        case let .claim(item: item, coverage: coverage, balance: balance):
            items = [NewClaimCellModel(objectName: item.name, objectPhoto: item.photo, objectLocation: item.location,
                                       date: Date(),
                                       expenses: nil, deductible: balance, coverage: coverage,
                                       descriptionText: "",
                                       photos: [],
                                       reimburseText: "")]
            self.coverage = coverage
        case .newChat:
            items = [NewDiscussionCellModel(postTitleText: "", descriptionText: "")]
        }
        
    }
    
    func reportModel(imageStrings: [String]) -> ReportModel? {
        guard let teamID = service.session?.currentTeam?.teamID else { fatalError("No current team") }
        
        switch context {
        case .claim:
            return claimModel(imageStrings: imageStrings, teamID: teamID)
        case .newChat:
            return newChatModel(teamID: teamID)
        }
    }
    
    func claimModel(imageStrings: [String], teamID: Int) -> NewClaimModel? {
        var date: Date?
        var expenses: Double?
        var message: String?
        var address: String?
        for model in items {
            if let model = model as? NewClaimCellModel {
                date = model.date
                expenses = model.expenses
                message = model.descriptionText
                let ethAddress = EthereumAddress(string: model.reimburseText)
                address = ethAddress?.string
            }
        }
        
        if let date = date, let expenses = expenses, let message = message, let address = address {
            let model = NewClaimModel(teamID: teamID,
                                      incidentDate: date,
                                      expenses: expenses,
                                      text: message,
                                      images: imageStrings,
                                      address: address,
                                      coverage: self.coverage,
                                      limit: self.limit)
            return model
        }
        return nil
    }
    
    func newChatModel(teamID: Int) -> NewChatModel? {
        var title: String?
        var text: String?
        for model in items {
            if let model = model as? NewDiscussionCellModel {
                title = model.postTitleText
                text = model.descriptionText
            }
        }
        
        if let text = text, let title = title {
            return NewChatModel(teamID: teamID, title: title, text: text)
        }
        return nil
    }
    
    func send(model: ReportModel, completion: @escaping (Any) -> Void) {
        if let model = model as? NewChatModel {
            sendNewChat(model: model, completion: completion)
        } else if let model = model as? NewClaimModel {
            sendClaim(model: model, completion: completion)
        }
    }
    
    private func sendNewChat(model: NewChatModel, completion: @escaping (Any) -> Void) {
        service.dao.createNewChat(model: model).observe { result in
            switch result {
            case let .value(claim):
                completion(claim)
            case .temporaryValue:
                break
            case let .error(error):
                completion(error)
            }
        }
    }
    
    private func sendClaim(model: NewClaimModel, completion: @escaping (Any) -> Void) {
        service.dao.createNewClaim(model: model).observe { result in
            switch result {
            case let .value(claim):
                completion(claim)
            case .temporaryValue:
                break
            case let .error(error):
                completion(error)
            }
        }
    }
    
    func getCoverageForDate(date: Date) {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        
        service.dao.requestCoverage(for: date, teamID: teamID).observe { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .value(coverageForDate):
                self.coverage = coverageForDate.coverage
                self.limit = coverageForDate.limit
                for (idx, item) in self.items.enumerated() {
                    if var item = item as? NewClaimCellModel {
                        item.coverage = coverageForDate.coverage
                        
                        self.items[idx] = item
                        self.onUpdateCoverage?()
                        break
                    }
                }
            case .temporaryValue:
                break
            case .error:
                break
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> ReportCellModel {
        get {
            return items[indexPath.row]
        }
    }
}
