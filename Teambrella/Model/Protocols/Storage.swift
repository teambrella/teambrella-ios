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
    func requestHome(teamID: Int) -> Future<HomeScreenModel>
    func requestTeamFeed(context: FeedRequestContext) -> Future<[FeedEntity]>
    
    func myProxy(userID: String, add: Bool) -> Future<Bool>
}
