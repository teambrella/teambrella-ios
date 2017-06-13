//
//  CellDecorator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct CellDecorator {
    static func shadow(for cell: UICollectionViewCell) {
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 2.0
        cell.layer.masksToBounds = false
    }
    
    static func roundedEdges(for cell: UICollectionViewCell) {
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 4
    }
}
