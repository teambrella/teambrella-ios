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

struct ReportDataSource {
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
    
    init(context: ReportContext) {
        self.context = context
        switch context {
        case let .claim(item: item, coverage: coverage, balance: balance):
            items = [ItemReportCellModel(name: item.name, photo: item.photo, location: item.location),
                     DateReportCellModel(date: Date()),
                     ExpensesReportCellModel(expenses: 0, deductible: balance, coverage: coverage),
                     DescriptionReportCellModel(text: ""),
                     PhotosReportCellModel(photos: []),
                     WalletReportCellModel(text: "")]
        case .newChat:
            items = [TitleReportCellModel(text: ""),
                     DescriptionReportCellModel(text: "")]
        }
        
    }
    
    func sendNewChat(completion: @escaping (Any) -> Void) {
        
    }
    
    func sendClaim(model: NewClaimModel, completion: @escaping (Any) -> Void) {
        service.storage.createNewClaim(model: model).observe { result in
            switch result {
            case let .value(claim):
                completion(claim)
            case let .error(error):
                completion(error)
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> ReportCellModel {
        get {
            return items[indexPath.row]
        }
    }
}
