//
//  JoinTeamCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.

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

struct JoinTeamCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(JoinTeamGreetingCell.nib, forCellWithReuseIdentifier: JoinTeamGreetingCell.cellID)
        collectionView.register(JoinTeamInfoCell.nib, forCellWithReuseIdentifier: JoinTeamInfoCell.cellID)
        collectionView.register(JoinTeamPersonalCell.nib, forCellWithReuseIdentifier: JoinTeamPersonalCell.cellID)
        collectionView.register(JoinTeamItemCell.nib, forCellWithReuseIdentifier: JoinTeamItemCell.cellID)
        collectionView.register(JoinTeamMessageCell.nib, forCellWithReuseIdentifier: JoinTeamMessageCell.cellID)
        collectionView.register(JoinTeamTermsCell.nib, forCellWithReuseIdentifier: JoinTeamTermsCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: JoinTeamCellModel) {
        if let cell = cell as? JoinTeamGreetingCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? JoinTeamInfoCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? JoinTeamPersonalCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? JoinTeamItemCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? JoinTeamMessageCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? JoinTeamTermsCell {
            populate(cell: cell, with: model)
        }
    }
    
    static func populate(cell: JoinTeamGreetingCell, with model: JoinTeamCellModel) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF")
        cell.greetingLabel.text = "Team.JoinTeamVC.GreetingCell.greeting".localized("Frank")
        ViewDecorator.roundedEdges(for: cell)
        ViewDecorator.shadow(for: cell)
        let boldString = "Deductable Savers "
        let nonBoldString = "team are the best team for insuring olders cars. We’re just going to need a few details."
        let resultString = boldString + nonBoldString
        let range = NSRange(location: boldString.count, length: nonBoldString.count)
        cell.textLabel.attributedText =  resultString.attributedBoldString(nonBoldRange: range)
    }
    
    static func populate(cell: JoinTeamInfoCell, with model: JoinTeamCellModel) {
        cell.headerLabel.text = "Team.JoinTeamVC.InfoCell.headerLabel".localized
        cell.numberBar.left?.titleLabel.text = "Team.JoinTeamVC.InfoCell.numberBar.left".localized
        cell.numberBar.left?.amountLabel.text = "159" //
        cell.numberBar.left?.currencyLabel.isHidden = true
        cell.numberBar.left?.badgeLabel.isHidden = true
        cell.numberBar.right?.titleLabel.text = "Team.JoinTeamVC.InfoCell.numberBar.right".localized
        cell.numberBar.right?.amountLabel.text = "24" //
        cell.numberBar.right?.currencyLabel.isHidden = true
        cell.numberBar.right?.badgeLabel.isHidden = true
        cell.rulesButton.setTitle("Team.JoinTeamVC.InfoCell.rulesButton".localized, for: .normal)
    }
    
    static func populate(cell: JoinTeamPersonalCell, with model: JoinTeamCellModel) {
        cell.headerLabel.text = "Team.JoinTeamVC.PersonalCell.headerLabel".localized
        cell.name.headerLabel.text = "Team.JoinTeamVC.PersonalCell.name".localized
        cell.name.textField.text = "Frank Smith"
        cell.dateOfBirth.headerLabel.text = "Team.JoinTeamVC.PersonalCell.birthday".localized
        cell.dateOfBirth.textField.text = "11/30/1989"
        cell.status.headerLabel.text = "Team.JoinTeamVC.PersonalCell.status".localized
        cell.status.textField.text = "Single"
        cell.location.headerLabel.text = "Team.JoinTeamVC.PersonalCell.location".localized
        cell.location.textField.text = "Amsterdam, The Netherlands"
        let verticalOffset: CGFloat = isSmallIPhone ? 8 : 19
        cell.verticalSpacings.forEach { $0.constant = verticalOffset }
    }
    static func populate(cell: JoinTeamItemCell, with model: JoinTeamCellModel) {
        cell.headerLabel.text = "Team.JoinTeamVC.ItemCell.headerLabel".localized
        cell.makeAndModel.headerLabel.text = "Team.JoinTeamVC.ItemCell.makeModel".localized
        cell.makeAndModel.textField.text = "Ford Focus S"
        cell.year.headerLabel.text = "Team.JoinTeamVC.ItemCell.year".localized
        cell.year.textField.text = "2016"
        cell.currency.headerLabel.text = "Team.JoinTeamVC.ItemCell.currency".localized
        cell.currency.textField.text = "usd".uppercased()
        cell.estimatedPrice.headerLabel.text = "Team.JoinTeamVC.ItemCell.price".localized
        cell.estimatedPrice.textField.text = "$17000"
        cell.objectPhotosLabel.text = "Team.JoinTeamVC.ItemCell.objectPhotos".localized
    }
    static func populate(cell: JoinTeamMessageCell, with model: JoinTeamCellModel) {
        cell.message.delegate = cell
        cell.headerLabel.text = "Team.JoinTeamVC.MessageCell.headerLabel".localized
        cell.secondLabel.text = "Team.JoinTeamVC.MessageCell.messageTitle".localized
        cell.message.layer.borderWidth = 1
        cell.message.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        cell.message.layer.cornerRadius = 3
        cell.placeholder.text = "Team.JoinTeamVC.MessageCell.placeholder".localized
    }
    
    static func populate(cell: JoinTeamTermsCell, with model: JoinTeamCellModel) {
        cell.headerLabel.text = "Team.JoinTeamVC.TermsCell.headerLabel".localized
        // swiftlint:disable:next line_length
        cell.textView.text = "This team covers Jimmy Wong for the amount of their regular collision policy deductible. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Nulla vitae elit libero, a pharetra augue. Cras mattis consectetur purus sit amet fermentum. Nullam id dolor id nibh ultricies vehicula ut id elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Nullam quis risus eget urna mollis ornare vel eu leo. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Maecenas faucibus mollis interdum. Nulla vitae elit libero, a pharetra augue. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Nullam quis risus eget urna mollis ornare vel eu leo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Curabitur blandit tempus porttitor. Donec sed odio dui. Aenean lacinia bibendum nulla sed consectetur."
        cell.textView.contentInset.left = 0
        
        cell.nonBoldString = "Team.JoinTeamVC.TermsCell.nonBold".localized
        cell.boldString = "Team.JoinTeamVC.TermsCell.bold".localized
        let resultString = cell.nonBoldString + cell.boldString
        let range = NSRange(location: 0, length: cell.nonBoldString.count)
        cell.bottomLabel.attributedText = resultString.attributedBoldString(nonBoldRange: range)
    }
}
