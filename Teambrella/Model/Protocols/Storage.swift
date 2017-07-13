//
//  Storage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

typealias ErrorHandler = (Error?) -> Void

protocol Storage {
    mutating func requestHome(teamID: Int,
                              success: @escaping (HomeScreenModel) -> Void,
                              failure: @escaping (Error?) -> Void)
    
    mutating func requestTeamFeed(teamID: Int,
                                  since: UInt64,
                                  offset: Int,
                                  limit: Int,
                                  success: @escaping([FeedEntity]) -> Void,
                                  failure: @escaping ErrorHandler)
}
