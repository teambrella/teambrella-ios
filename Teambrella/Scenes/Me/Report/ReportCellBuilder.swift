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
        collectionView.register(NewDiscussionCell.nib, forCellWithReuseIdentifier: NewDiscussionCell.cellID)
        collectionView.register(NewClaimCell.nib, forCellWithReuseIdentifier: NewClaimCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell,
                         with model: ReportCellModel,
                         reportVC: ReportVC,
                         indexPath: IndexPath) {
        switch cell {
        case let cell as NewDiscussionCell:
            populateNewDiscussion(cell: cell, model: model, reportVC: reportVC, indexPath: indexPath)
        case let cell as NewClaimCell:
            populateNewClaim(cell: cell, model: model, reportVC: reportVC, indexPath: indexPath)
        default:
            break
        }
    }
    
    static func populateNewDiscussion(cell: NewDiscussionCell,
                                      model: ReportCellModel,
                                      reportVC: ReportVC,
                                      indexPath: IndexPath) {
        if let model = model as? NewDiscussionCellModel {
            cell.headerLabel.text = model.title
            cell.textFieldTitleLabel.text = model.postTitle
            cell.titleTextField.inputView = nil
            cell.titleTextField.delegate = reportVC
            cell.titleTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isTitleValid : false
            cell.titleTextField.text = model.postTitleText
            cell.titleTextField.tintColor = cell.titleTextField.tintColor.withAlphaComponent(1)
            cell.titleTextField.tag = indexPath.row
            cell.titleTextField.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.titleTextField.addTarget(reportVC,
                                          action: #selector(ReportVC.textFieldDidChange),
                                          for: .editingChanged)
            cell.textViewTitleLabel.text = model.descriptionTitle
            cell.postTextView.text = model.descriptionText
            cell.postTextView.tag = indexPath.row
            cell.postTextView.delegate = reportVC
            cell.postTextView.isInAlertMode = reportVC.isInCorrectionMode ? !model.isDescriptionValid : false
        }
    }
    
    // swiftlint:disable:next function_body_length
    static func populateNewClaim(cell: NewClaimCell,
                                 model: ReportCellModel,
                                 reportVC: ReportVC,
                                 indexPath: IndexPath) {
        if let model = model as? NewClaimCellModel {
            cell.headerLabel.text = model.title
            cell.objectImageView.show(model.objectPhoto)
            cell.objectNameLabel.text = model.objectName.entire
            cell.objectDetailsLabel.text = model.objectLocation
            
            cell.dateLabel.text = model.dateTitle
            cell.dateTextField.inputView = nil
            cell.dateTextField.inputView = reportVC.datePicker
            cell.dateTextField.text = DateProcessor().stringIntervalOrDate(from: model.date)
            cell.dateTextField.tintColor = cell.dateTextField.tintColor.withAlphaComponent(0)
            
            cell.expensesLabel.text = model.expensesTitle
            cell.statsNumberBar.left?.titleLabel.text = model.deductibleTitle
            cell.statsNumberBar.left?.amountLabel.text = model.deductibleString
            cell.statsNumberBar.left?.currencyLabel.text = service.currencyName
            cell.statsNumberBar.middle?.titleLabel.text = model.coverageTitle
            cell.statsNumberBar.middle?.amountLabel.text = model.coverageString
            cell.statsNumberBar.middle?.currencyLabel.text = "%"
            cell.statsNumberBar.middle?.isCurrencyOnTop = false
            if reportVC.isInCorrectionMode && model.coverage.value <= 0 {
                cell.statsNumberBar.middle?.titleLabel.textColor = .red
                cell.statsNumberBar.middle?.amountLabel.textColor = .red
            } else if let left = cell.statsNumberBar.left {
                cell.statsNumberBar.middle?.titleLabel.textColor = left.titleLabel.textColor
                cell.statsNumberBar.middle?.amountLabel.textColor = left.amountLabel.textColor
            }
            cell.statsNumberBar.right?.titleLabel.text = model.amountTitle
            cell.statsNumberBar.right?.amountLabel.text = model.amountString
            cell.statsNumberBar.right?.currencyLabel.text = service.currencyName
            cell.expensesTextField.delegate = reportVC
            cell.expensesTextField.text = model.expensesString
            cell.expensesTextField.placeholder = "Max: \(Int(reportVC.limit))"
            cell.expensesTextField.keyboardType = .decimalPad
            cell.expensesTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isExpensesValid : false
            cell.expensesTextField.rightViewMode = .unlessEditing
            cell.currencyTextField.isUserInteractionEnabled = false
            cell.currencyTextField.text = service.currencyName
            cell.expensesTextField.tag = indexPath.row
            cell.expensesTextField.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.expensesTextField.addTarget(reportVC,
                                             action: #selector(ReportVC.textFieldDidChange),
                                             for: .editingChanged)
            
            cell.descriptionLabel.text = model.descriptionTitle
            cell.descriptionTextView.text = model.descriptionText
            cell.descriptionTextView.tag = indexPath.row
            cell.descriptionTextView.delegate = reportVC
            cell.descriptionTextView.isInAlertMode = reportVC.isInCorrectionMode ? !model.isDescriptionValid : false
            
            cell.photosLabel.text = model.photosTitle
            cell.addPhotosButton.setTitle(model.buttonTitle, for: .normal)
            cell.addPhotosButton.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.addPhotosButton.addTarget(reportVC, action: #selector(ReportVC.tapAddPhoto), for: .touchUpInside)
            
            cell.reimburseLabel.text = model.reimburseTitle
            cell.reimburseTextField.inputView = nil
            
            cell.reimburseTextField.delegate = reportVC
            cell.reimburseTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isReimburseValid : false
            cell.reimburseTextField.text = model.reimburseText
            cell.reimburseTextField.tintColor = cell.reimburseTextField.tintColor.withAlphaComponent(1)
            cell.reimburseTextField.placeholder = ""
            cell.reimburseTextField.tag = indexPath.row
            cell.reimburseTextField.removeTarget(reportVC, action: nil, for: .allEvents)
            cell.reimburseTextField.addTarget(reportVC,
                                              action: #selector(ReportVC.textFieldDidChange),
                                              for: .editingChanged)
        }
        
    }
}
