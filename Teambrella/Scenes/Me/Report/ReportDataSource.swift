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

enum ReportType {
    case claim
}

struct ReportDataSource {
    enum ReportCellType {
        case item
        case date
        case expenses
        case description
        case photos
        case wallet
    }
    
    var items: [ReportCellType] = []
    var count: Int { return items.count }
    
    init(reportType: ReportType) {
       items = [.item, .date, .expenses, .description, .photos, .wallet]
    }
    
    subscript(indexPath: IndexPath) -> ReportCellType {
        return items[indexPath.row]
    }
}
