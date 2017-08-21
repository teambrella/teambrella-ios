//
//  Storage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

typealias ErrorHandler = (Error?) -> Void

protocol Storage {
    func requestHome(teamID: Int) -> Future<HomeScreenModel>
    func requestTeamFeed(context: FeedRequestContext) -> Future<[FeedEntity]>
    func deleteCard(topicID: String) -> Future<HomeScreenModel>
    func setLanguage() -> Future<String>
    
    func myProxy(userID: String, add: Bool) -> Future<Bool>
}
