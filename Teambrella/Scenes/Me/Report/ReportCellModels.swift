//
//  ReportCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
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
    
    let name: String
    let photo: String
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
    var deductible: Double
    var deductibleString: String { return String.truncatedNumber(deductible) }
    var coverage: Double
    var coverageString: String { return String.truncatedNumber(coverage * 100) }
    var isValid: Bool {
        guard let expenses = expenses else { return false }
        
        return expenses > 0
    }
    var amountString: String { return String.truncatedNumber(expenses ?? 0 * coverage) }
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
    
    var isValid: Bool { return text != "" }
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
