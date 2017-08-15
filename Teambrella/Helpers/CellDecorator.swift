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

struct CellDecorator {
    static func shadow(for cell: UICollectionReusableView) {
        shadow(for: cell, opacity: 0.08, radius: 4)
    }
    
    static func heavyShadow(for cell: UICollectionReusableView) {
        shadow(for: cell, opacity: 0.2, radius: 5, offset: CGSize(width: 0, height: 1))
    }
    
    static func shadow(for view: UIView,
                       opacity: Float,
                       radius: Float,
                       offset: CGSize = CGSize.zero) {
        view.layer.shadowColor = UIColor.black.cgColor
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
}
