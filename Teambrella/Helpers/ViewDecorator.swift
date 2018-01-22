//
//  CellDecorator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.06.17.

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
import SnapKit

struct ViewDecorator {
    static func shadow(for cell: UICollectionReusableView) {
        shadow(for: cell, color: #colorLiteral(red: 0.8705882353, green: 0.8901960784, blue: 0.9098039216, alpha: 1), opacity: 1, radius: 4, offset: CGSize(width: 0, height: 2))
    }
    
    static func heavyShadow(for cell: UICollectionReusableView) {
        shadow(for: cell, opacity: 0.2, radius: 5, offset: CGSize(width: 0, height: 1))
    }
    
    static func homeCardShadow(for view: UIView) {
        shadow(for: view, color: #colorLiteral(red: 0.08235294118, green: 0.2078431373, blue: 0.3529411765, alpha: 0.2000214041), opacity: 1, radius: 5, offset: CGSize(width: 0, height: 5))
    }
    
    static func shadow(for view: UIView,
                       color: UIColor = UIColor.black,
                       opacity: Float,
                       radius: Float,
                       offset: CGSize = CGSize.zero) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOffset = offset
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = CGFloat(radius)
        view.layer.masksToBounds = false
        
    }
    
    static func removeShadow(for cell: UICollectionReusableView) {
        cell.layer.shadowOpacity = 0
    }
    
    static func roundedEdges(for cell: UICollectionReusableView) {
        if let cell = cell as? UICollectionViewCell {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 4
        } else {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 4
        }
    }
    
    static func addCloseButton(for cell: UICollectionReusableView) {
        guard var closableCell = cell as? ClosableCell, closableCell.closeButton == nil else { return }
        
        let closeButton = UIButton()
        closeButton.setImage(#imageLiteral(resourceName: "closeIcon"), for: .normal)
        cell.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalTo(cell)
            make.top.equalTo(cell)
            make.width.height.equalTo(40)
        }
        closableCell.closeButton = closeButton
    }
    
    static func decorateCollectionView(cell: UICollectionReusableView, isFirst: Bool, isLast: Bool) {
        if isFirst && isLast {
            shadow(for: cell, opacity: 0.1, radius: 8, offset: CGSize.init(width: 0, height: 0))
        } else if isFirst {
            shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: -4))
        } else if isLast {
            shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: 4))
        } else {
            removeShadow(for: cell)
        }
    }
}

protocol ClosableCell {
    var closeButton: UIButton! { get set }
}
