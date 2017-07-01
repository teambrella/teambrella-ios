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
    static var cellID = "joinTeamGreetingCell"
}

struct JoinTeamInfoCellModel: JoinTeamCellModel {
    static var cellID = "joinTeamGreetingCell"
}

struct JoinTeamPersonalCellModel: JoinTeamCellModel {
    static var cellID = "joinTeamGreetingCell"
}

struct JoinTeamItemCellModel: JoinTeamCellModel {
    static var cellID = "joinTeamGreetingCell"
}

struct JoinTeamMessageCellModel: JoinTeamCellModel {
    static var cellID = "joinTeamGreetingCell"
}

struct JoinTeamTermsCellModel: JoinTeamCellModel {
    static var cellID = "joinTeamGreetingCell"
}
