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
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 4.0
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
