//
//  XIBInitableCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol XIBInitableCell {
    static var nib: UINib { get }
    static var cellID: String { get }
}

extension XIBInitableCell where Self: UICollectionViewCell {
    static var nib: UINib { return UINib(nibName: "\(self)", bundle: nil) }
    static var cellID: String { return "\(self)" }
}
