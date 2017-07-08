//
//  HomeCellModels.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 08.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol HomeCellModel {
    static var cellID: String { get }
}

struct HomeSupportCellModel: HomeCellModel {
    static var cellID = HomeSupportCell.cellID
}

struct HomeApplicationDeniedCellModel: HomeCellModel {
    static var cellID = HomeApplicationDeniedCell.cellID
}

struct HomeApplicationAcceptedCellModel: HomeCellModel {
    static var cellID = HomeApplicationAcceptedCell.cellID
}

struct HomeApplicationStatusCellModel: HomeCellModel {
    static var cellID = HomeApplicationStatusCell.cellID
}
