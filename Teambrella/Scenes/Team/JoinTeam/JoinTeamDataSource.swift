//
//  JoinTeamDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct JoinTeamDataSource {
    var cellModels: [JoinTeamCellModel] = []
    var count: Int { return cellModels.count }
    
    subscript(indexPath: IndexPath) -> JoinTeamCellModel {
        return cellModels[indexPath.row]
    }
}

extension JoinTeamDataSource {
    mutating func createFakeCells() {
        cellModels = [JoinTeamGreetingCellModel(),
                      JoinTeamInfoCellModel(),
                      JoinTeamPersonalCellModel(),
                      JoinTeamItemCellModel(),
                      JoinTeamMessageCellModel(),
                      JoinTeamTermsCellModel()]
    }
}
