//
/* Copyright(C) 2018 Teambrella, Inc.
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

/**
 Firebase payload

 Firebase is not capable of inserting nested dictionaries so we have to use flat design of notification payload
 */
protocol NotificationPayloadProtocol {
    var cmd: Int { get }
    var teamId: Int { get }
    var senderUserId: String? { get }
    var senderAvatar: String? { get }
    var senderUserName: String? { get }
    var topicId: String? { get }
    var postId: String? { get }
    var content: String? { get }
    var count: Int { get }
    var teammateUserId: String? { get }
    var teammateUserName: String? { get }
    var teammateAvatar: String? { get }
    var claimId: Int { get }
    var claimerName: String? { get }
    var claimPhoto: String? { get }
    var claimObjectName: String? { get }
    var isMyTopic: Bool { get }
    var topicName: String? { get }
    var discussionTopicName: String? { get }
    var message: String? { get }
    var balanceFiat: String? { get }
    var balanceCrypto: String? { get }
    var teamLogo: String? { get }
    var teamName: String? { get }
    var amount: String? { get }
    var debug: Bool { get }
}
