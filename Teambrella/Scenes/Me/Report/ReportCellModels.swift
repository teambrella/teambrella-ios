//
//  ReportCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.08.17.
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
//

import Foundation

protocol ReportCellModel {
    var cellReusableIdentifier: String { get }
    var preferredHeight: Float { get }
    var title: String { get }
    var isValid: Bool { get }
}

struct ItemReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportItemCell.cellID }
    var preferredHeight: Float { return 120 }
    let title = "Me.Report.ItemCell.title".localized
    
    let name: Name
    let photo: Photo
    let location: String
    
    var isValid: Bool { return true }
}

struct DateReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTextFieldCell.cellID }
    var preferredHeight: Float { return 80 }
    let title = "Me.Report.DateCell.title".localized
    var date: Date
    
    var isValid: Bool { return true }
}

struct ExpensesReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportExpensesCell.cellID }
    var preferredHeight: Float { return 160 }
    let title = "Me.Report.ExpensesCell.title".localized
    let deductibleTitle = "Me.Report.ExpensesCell.deductibleTitle".localized
    let coverageTitle = "Me.Report.ExpensesCell.coverageTitle".localized
    let amountTitle = "Me.Report.ExpensesCell.amountTitle".localized
    var expenses: Double?
    var expensesString: String { return expenses.map { String.truncatedNumber($0) } ?? "" }
    var deductible: Ether
    var deductibleString: String { return String.truncatedNumber(MEth(deductible).value) }
    var coverage: Coverage
    var coverageString: String { return String.truncatedNumber(coverage.percentage) }
    var isValid: Bool {
        guard let expenses = expenses else { return false }
        
        return expenses > 0
    }
    var amountString: String { return String.truncatedNumber((expenses ?? 0) * coverage.value) }
}

struct DescriptionReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportDescriptionCell.cellID }
    var preferredHeight: Float { return 170 }
    let title: String
    var text: String
    
    var isValid: Bool { return title != "" && text != "" }
}

struct PhotosReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportPhotoGalleryCell.cellID }
    var preferredHeight: Float { return 145 }
    let title = "Me.Report.PhotosCell.title".localized
    let buttonTitle = "Me.Report.PhotosCell.buttonTitle".localized
    var photos: [String]
    
    var isValid: Bool { return true }
}

struct WalletReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTextFieldCell.cellID }
    var preferredHeight: Float { return 80 }
    let title = "Me.Report.WalletCell.title".localized
    var text: String
    
    var isValid: Bool { return EthereumAddress(string: text) != nil }
}

struct TitleReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTextFieldCell.cellID }
    var preferredHeight: Float { return 80 }
    let title = "Me.Report.TitleCell.title".localized
    var text: String
    
    var isValid: Bool { return text != "" }
}

struct HeaderTitleReportCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return ReportTitleCell.cellID }
    var preferredHeight: Float { return 70 }
    let title = "Me.Report.HeaderTitleCell.title".localized
    
    var isValid: Bool { return true }
}

struct NewDiscussionCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return NewDiscussionCell.cellID }
    var preferredHeight: Float { return 288 }
    let title = "Me.Report.HeaderTitleCell.title".localized
    
    var isValid: Bool { return isTitleValid && isDescriptionValid }
    
    let postTitle = "Me.Report.TitleCell.title".localized
    var postTitleText: String
    var isTitleValid: Bool { return postTitleText != "" }
    
    let descriptionTitle = "Me.Report.DescriptionCell.title-discussion".localized
    var descriptionText: String
    var isDescriptionValid: Bool { return descriptionText != "" }
}
