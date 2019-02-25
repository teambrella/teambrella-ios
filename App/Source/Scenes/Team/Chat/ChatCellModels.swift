//
//  ChatCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
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
//

import Foundation

protocol ChatCellModel {
    var id: String { get }
    var date: Date { get }
    var updated: Int64 { get }
    var isTemporary: Bool { get }
}

protocol ChatCellUserDataLike: ChatCellModel {
    var entity: ChatEntity { get }
    var fragments: [ChatFragment] { get }
    var isMy: Bool { get }
    var userAvatar: Avatar? { get }
    var date: Date { get }
    var liked: Int { get set }
    var myLike: Int { get set }
    var grayed: Double { get }
    var updated: Int64 { get }
    var isTemporary: Bool { get }
    var id: String { get }
    var isDeletable: Bool { get }
}

struct ChatTextCellModel: ChatCellUserDataLike {
    let entity: ChatEntity
    let fragments: [ChatFragment]
    let fragmentSizes: [CGSize]
    
    let isMy: Bool
    let userName: Name
    let userAvatar: Avatar?
    var rateText: String?
    let date: Date
    var liked: Int
    var myLike: Int
    var grayed: Double
    let updated: Int64
    let isTemporary: Bool
    let isDeletable: Bool = false

    var maxFragmentsWidth: CGFloat { return fragmentSizes.reduce(0) { max($0, $1.width) } }
    var totalFragmentsHeight: CGFloat { return fragmentSizes.reduce(0) { $0 + $1.height } }
    var id: String { return entity.id }
    var isSingleText: Bool { return fragments.count == 1 }
}

struct ChatImageCellModel: ChatCellUserDataLike {
    let entity: ChatEntity
    let fragments: [ChatFragment]
    let fragmentSizes: [CGSize]

    let isMy: Bool
    let userAvatar: Avatar?
    let date: Date
    var liked: Int
    var myLike: Int
    var grayed: Double
    let updated: Int64
    let isTemporary: Bool
    let isDeletable: Bool

    var maxFragmentsWidth: CGFloat { return fragmentSizes.reduce(0) { max($0, $1.width) } }
    var totalFragmentsHeight: CGFloat { return fragmentSizes.reduce(0) { $0 + $1.height } }
    var id: String { return entity.id }
}

struct ChatUnsentImageCellModel: ChatCellModel {
    let id: String
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool
    let isDeletable: Bool 
    var isSent: Bool

}

struct ChatSeparatorCellModel: ChatCellModel {
    var id: String { return String(describing: date.timeIntervalSince1970) }
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool = true
}

struct ChatNewMessagesSeparatorModel: ChatCellModel {
    var id: String { return "newMessages" }
    let date: Date
    let updated: Int64 = 0
    let text: String = "Team.Chat.Separator.newMessages".localized
    let isTemporary: Bool = true
}

struct ChatClaimPaidCellModel: ChatCellModel {
    var id: String { return String(describing: date.timeIntervalSince1970) }
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool = false
}

struct VotingStatsCellModel: ChatCellModel {
    var id: String { return String(describing: date.timeIntervalSince1970) }
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool = false
    
    let risksVotesAsTeamOrBetter: Double
    let claimsVotesAsTeamOrBetter: Double
}

protocol ServiceMessageLike: ChatCellModel {
    var text: String { get }
    var size: CGSize { get }
}

struct ServiceMessageCellModel: ServiceMessageLike {
    var id: String { return "\(type(of: self))|\(messageID)|\(date.timeIntervalSince1970)" }
    let messageID: String
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool = false
    let text: String
    let size: CGSize
    let command: ServiceMessageCommand?
}

struct ServiceMessageWithButtonCellModel: ServiceMessageLike {
    var id: String { return "\(type(of: self))|\(date.timeIntervalSince1970)" }
    let messageID: String
    let date: Date
    let updated: Int64 = 0
    let isTemporary: Bool = false
    let text: String
    let buttonText: String
    let size: CGSize
    let command: ServiceMessageCommand
}

enum ServiceMessageCommand {
    case addPhoto
    case addMorePhoto
    case needFunding
}
