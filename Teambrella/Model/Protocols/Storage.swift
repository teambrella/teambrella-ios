//
//  Storage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol Storage {
    mutating func requestHome(teamID: Int,
                              success: @escaping (HomeScreenModel) -> Void,
                              failure: @escaping (Error?) -> Void)
}
