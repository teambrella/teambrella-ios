//
//  JoinTeamCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol JoinTeamCellModel {
    static var cellID: String { get }
}

struct JoinTeamGreetingCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamGreetingCell.cellID
}

struct JoinTeamInfoCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamInfoCell.cellID
}

struct JoinTeamPersonalCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamPersonalCell.cellID
}

struct JoinTeamItemCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamItemCell.cellID
}

struct JoinTeamMessageCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamMessageCell.cellID
}

struct JoinTeamTermsCellModel: JoinTeamCellModel {
    static var cellID = JoinTeamTermsCell.cellID
}
