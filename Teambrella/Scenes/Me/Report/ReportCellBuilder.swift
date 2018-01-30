//
//  ReportCellBuilder.swift
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

struct ReportCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(ReportItemCell.nib, forCellWithReuseIdentifier: ReportItemCell.cellID)
        collectionView.register(ReportExpensesCell.nib, forCellWithReuseIdentifier: ReportExpensesCell.cellID)
        collectionView.register(ReportDescriptionCell.nib, forCellWithReuseIdentifier: ReportDescriptionCell.cellID)
        collectionView.register(ReportPhotoGalleryCell.nib, forCellWithReuseIdentifier: ReportPhotoGalleryCell.cellID)
        collectionView.register(ReportTextFieldCell.nib, forCellWithReuseIdentifier: ReportTextFieldCell.cellID)
        collectionView.register(ReportTitleCell.nib, forCellWithReuseIdentifier: ReportTitleCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell,
                         with model: ReportCellModel,
                         reportVC: ReportVC,
                         indexPath: IndexPath) {
        switch cell {
        case let cell as ReportItemCell:
            populateItem(cell: cell, model: model)
        case let cell as ReportExpensesCell:
            populateExpenses(cell: cell, model: model, reportVC: reportVC, indexPath: indexPath)
        case let cell as ReportDescriptionCell:
            populateDescription(cell: cell, model: model, reportVC: reportVC, indexPath: indexPath)
        case let cell as ReportPhotoGalleryCell:
            populatePhotoGallery(cell: cell, model: model, reportVC: reportVC)
        case let cell as ReportTextFieldCell:
            populateTextField(cell: cell, model: model, reportVC: reportVC, indexPath: indexPath)
        case let cell as ReportTitleCell:
            cell.titleLabel.text = model.title
        default:
            break
        }
    }
    
    static func populateItem(cell: ReportItemCell, model: ReportCellModel) {
        guard let model = model as? ItemReportCellModel else { return }
        
        cell.avatarView.showImage(string: model.photo)
        cell.itemLabel.text = model.name
        cell.detailsLabel.text = model.location
        cell.headerLabel.text = model.title
    }
    
    static func populateExpenses(cell: ReportExpensesCell,
                                 model: ReportCellModel,
                                 reportVC: ReportVC,
                                 indexPath: IndexPath) {
        guard let model = model as? ExpensesReportCellModel else { return }
        
        cell.headerLabel.text = model.title
        cell.numberBar.left?.titleLabel.text = model.deductibleTitle
        cell.numberBar.left?.amountLabel.text = model.deductibleString
        cell.numberBar.left?.currencyLabel.text = service.currencySymbol
        
        cell.numberBar.middle?.titleLabel.text = model.coverageTitle
        cell.numberBar.middle?.amountLabel.text = model.coverageString
        cell.numberBar.middle?.currencyLabel.text = "%"
        cell.numberBar.middle?.isCurrencyOnTop = false
        if reportVC.isInCorrectionMode && model.coverage.value <= 0 {
            cell.numberBar.middle?.titleLabel.textColor = .red
            cell.numberBar.middle?.amountLabel.textColor = .red
        } else if let left = cell.numberBar.left {
            cell.numberBar.middle?.titleLabel.textColor = left.titleLabel.textColor
            cell.numberBar.middle?.amountLabel.textColor = left.amountLabel.textColor
        }
        
        cell.numberBar.right?.titleLabel.text = model.amountTitle
        cell.numberBar.right?.amountLabel.text = model.amountString
        cell.numberBar.right?.currencyLabel.text = service.currencySymbol
        
        cell.expensesTextField.delegate = reportVC
        cell.expensesTextField.text = model.expensesString
        cell.expensesTextField.keyboardType = .decimalPad
        cell.expensesTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
        cell.expensesTextField.rightViewMode = .unlessEditing
        
        cell.currencyTextField.isUserInteractionEnabled = false
        cell.currencyTextField.text = service.currencySymbol
        
        cell.expensesTextField.tag = indexPath.row
        cell.expensesTextField.removeTarget(reportVC, action: nil, for: .allEvents)
        cell.expensesTextField.addTarget(reportVC,
                                         action: #selector(ReportVC.textFieldDidChange),
                                         for: .editingChanged)
    }
    
    static func populateDescription(cell: ReportDescriptionCell,
                                    model: ReportCellModel,
                                    reportVC: ReportVC,
                                    indexPath: IndexPath) {
        guard let model = model as? DescriptionReportCellModel else { return }
        
        cell.headerLabel.text = model.title
        cell.textView.text = model.text
        cell.textView.tag = indexPath.row
        cell.textView.delegate = reportVC
        cell.textView.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
    }
    
    static func populatePhotoGallery(cell: ReportPhotoGalleryCell,
                                     model: ReportCellModel,
                                     reportVC: ReportVC) {
        guard let model = model as? PhotosReportCellModel else { return }
        
        cell.headerLabel.text = model.title
        cell.button.setTitle(model.buttonTitle, for: .normal)
        cell.button.removeTarget(reportVC, action: nil, for: .allEvents)
        cell.button.addTarget(reportVC, action: #selector(ReportVC.tapAddPhoto), for: .touchUpInside)
    }
    
    static func populateTextField(cell: ReportTextFieldCell,
                                  model: ReportCellModel,
                                  reportVC: ReportVC,
                                  indexPath: IndexPath) {
        cell.headerLabel.text = model.title
        cell.textField.inputView = nil
        switch model {
        case let model as DateReportCellModel:
            cell.textField.inputView = reportVC.datePicker
            cell.textField.text = DateProcessor().stringIntervalOrDate(from: model.date)
            cell.textField.tintColor = cell.textField.tintColor.withAlphaComponent(0)
        case let model as WalletReportCellModel:
            cell.textField.delegate = reportVC
            cell.textField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            cell.textField.text = model.text
            cell.textField.tintColor = cell.textField.tintColor.withAlphaComponent(1)
            cell.textField.tag = indexPath.row
            cell.textField.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.textField.addTarget(reportVC, action: #selector(ReportVC.textFieldDidChange), for: .editingChanged)
        case let model as TitleReportCellModel:
            cell.textField.delegate = reportVC
            cell.textField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            cell.textField.text = model.text
            cell.textField.tintColor = cell.textField.tintColor.withAlphaComponent(1)
            cell.textField.tag = indexPath.row
            cell.textField.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.textField.addTarget(reportVC, action: #selector(ReportVC.textFieldDidChange), for: .editingChanged)
            cell.textField.placeholder = "Me.Report.newDiscussion.title-placeholder".localized
        default:
            break
        }
    }
    
}
