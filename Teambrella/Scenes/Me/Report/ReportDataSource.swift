//
//  ReportDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
