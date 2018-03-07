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

struct NewClaimCellModel: ReportCellModel {
    var cellReusableIdentifier: String { return NewClaimCell.cellID }
    var preferredHeight: Float { return 750 }
    let title = "Me.Report.ItemCell.title".localized
    var isValid: Bool { return isExpensesValid && isDescriptionValid && isReimburseValid }
    
    let objectName: Name
    let objectPhoto: Photo
    let objectLocation: String
    
    let dateTitle = "Me.Report.DateCell.title".localized
    var date: Date
    //    var isDateValid: Bool { return true }
    
    let expensesTitle = "Me.Report.ExpensesCell.title".localized
    let deductibleTitle = "Me.Report.ExpensesCell.deductibleTitle".localized
    let coverageTitle = "Me.Report.ExpensesCell.coverageTitle".localized
    let amountTitle = "Me.Report.ExpensesCell.amountTitle".localized
    var expenses: Double?
    var expensesString: String { return expenses.map { String.truncatedNumber($0) } ?? "" }
    var deductible: Ether
    var deductibleString: String { return String.truncatedNumber(MEth(deductible).value) }
    var coverage: Coverage
    var coverageString: String { return String.truncatedNumber(coverage.percentage) }
    var isExpensesValid: Bool {
        guard let expenses = expenses else { return false }
        
        return expenses > 0
    }
    var amountString: String { return String.truncatedNumber((expenses ?? 0) * coverage.value) }
    
    let descriptionTitle = "Me.Report.DescriptionCell.title".localized
    var descriptionText: String
    var isDescriptionValid: Bool { return descriptionTitle != "" && descriptionText != "" }
    
    let photosTitle = "Me.Report.PhotosCell.title".localized
    let buttonTitle = "Me.Report.PhotosCell.buttonTitle".localized
    var photos: [String]
    //    var isPhotosValid: Bool { return true }
    
    let reimburseTitle = "Me.Report.WalletCell.title".localized
    var reimburseText: String
    var isReimburseValid: Bool { return EthereumAddress(string: reimburseText) != nil }
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
