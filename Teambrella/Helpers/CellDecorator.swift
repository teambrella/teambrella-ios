//
//  CellDecorator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct CellDecorator {
    static func shadow(for cell: UICollectionReusableView) {
        shadow(for: cell, opacity: 0.08, radius: 4)
    }
    
    static func heavyShadow(for cell: UICollectionReusableView) {
        shadow(for: cell, opacity: 0.2, radius: 5, offset: CGSize(width: 0, height: 1))
    }
    
    static func shadow(for cell: UICollectionReusableView,
                       opacity: Float,
                       radius: Float,
                       offset: CGSize = CGSize.zero) {
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = offset
        cell.layer.shadowOpacity = opacity
        cell.layer.shadowRadius = CGFloat(radius)
        cell.layer.masksToBounds = false
        
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
