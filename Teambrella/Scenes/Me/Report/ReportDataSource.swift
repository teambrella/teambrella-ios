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
            break
        }
        
    }
    
    subscript(indexPath: IndexPath) -> ReportCellModel {
        return items[indexPath.row]
    }
}

protocol ReportCellModel {
    var cellReusableIdentifier: String { get }
    var preferredHeight: Float { get }
    var title: String { get }
}

struct ItemReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportItemCell.cellID }
    var preferredHeight: Float { return 120 }
    let title = "Me.Report.ItemCell.title".localized
    
    let name: String
    let photo: String
    let location: String
    
}

struct DateReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTextFieldCell.cellID }
    var preferredHeight: Float { return 80 }
    let title = "Me.Report.DateCell.title".localized
    var date: Date
}

struct ExpensesReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportExpensesCell.cellID }
    var preferredHeight: Float { return 160 }
    let title = "Me.Report.ExpensesCell.title".localized
    let deductibleTitle = "Me.Report.ExpensesCell.deductibleTitle".localized
    let coverageTitle = "Me.Report.ExpensesCell.coverageTitle".localized
    let amountTitle = "Me.Report.ExpensesCell.amountTitle".localized
    var expenses: Double
    var expensesString: String { return cryptoCoinsString(amount: expenses) }
    var deductible: Double
    var deductibleString: String { return cryptoCoinsString(amount: deductible) }
    var coverage: Double
    var coverageString: String { return cryptoCoinsString(amount: coverage) }
    
    private func cryptoCoinsString(amount: Double) -> String {
        return String.formattedNumber(amount * 1000)
    }
}

struct DescriptionReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportDescriptionCell.cellID }
    var preferredHeight: Float { return 170 }
    let title = "Me.Report.DescriptionCell.title".localized
    var text: String
    
}

struct PhotosReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportPhotoGalleryCell.cellID }
    var preferredHeight: Float { return 145 }
    let title = "Me.Report.PhotosCell.title".localized
    let buttonTitle = "Me.Report.PhotosCell.buttonTitle".localized
    var photos: [String]
    
}

struct WalletReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTextFieldCell.cellID }
    var preferredHeight: Float { return 80 }
    let title = "Me.Report.WalletCell.title".localized
    var text: String
}
