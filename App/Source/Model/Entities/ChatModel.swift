//
/* Copyright(C) 2017 Teambrella, Inc.
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

struct ChatModel: Decodable, CustomStringConvertible {
    var lastUpdated: Int64
    let discussion: DiscussionPart

    let basic: BasicPart?
    let team: TeamPart?
    var voting: VotingPart?

    let id: Int?
//    let lastRead: UInt64?
    //let title: String?

    var isClaimChat: Bool {
        return basic?.claimAmount != nil
    }

    var isApplicationChat: Bool {
        return basic?.risk != nil
    }

    var description: String { return "\(type(of: self)) \(discussion.topicID); messages: \(discussion.chat.count)" }

    mutating func update(with claimUpdate: ClaimVoteUpdate) {
        lastUpdated = claimUpdate.lastUpdated
        voting?.update(with: claimUpdate.voting)
    }

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "LastUpdated"
        case discussion = "DiscussionPart"
        case basic = "BasicPart"
        case team = "TeamPart"
        case voting = "VotingPart"
        case id = "Id"
        //case title = "Title"
//        case lastRead = "LastRead"
    }

    struct DiscussionPart: Decodable {
        let isMuted: Bool?
        let lastRead: UInt64
        let topicID: String
        let chat: [ChatEntity]

        enum CodingKeys: String, CodingKey {
            case isMuted = "IsMuted"
            case lastRead = "LastRead"
            case topicID = "TopicId"
            case chat = "Chat"
        }

    }

    struct VotingPart: Decodable {
        var remainingMinutes: Int
        var proxyName: Name?
        var proxyAvatar: Avatar?
        var myVote: Double?

        let riskVoted: Double?
        var ratioVoted: ClaimVote?

        var otherCount: Int?
        var otherAvatars: [Avatar]?

        mutating func update(with claim: ClaimEntityLarge.VotingPart) {
            remainingMinutes = claim.minutesRemaining
            proxyName = claim.proxyName
            proxyAvatar = claim.proxyAvatar
            myVote = claim.myVote?.value
            ratioVoted = claim.ratioVoted
            otherCount = claim.otherCount
            otherAvatars = claim.otherAvatars
        }

        enum CodingKeys: String, CodingKey {
            case remainingMinutes = "RemainedMinutes"
            case proxyName = "ProxyName"
            case proxyAvatar = "ProxyAvatar"
            case myVote = "MyVote"

            case riskVoted = "RiskVoted"

            case ratioVoted = "RatioVoted"
            case otherCount = "OtherCount"
            case otherAvatars = "OtherAvatars"
        }

    }

    struct BasicPart: Decodable {
        let userID: String
        let avatar: String
        let title: String?

        let model: String?
        let year: Year?
        let smallPhoto: String?
        let risk: Double?
        let claimLimit: Double?

        let name: Name?
        let deductible: Double?
        let bigPhotos: [String]?
        let smallPhotos: [String]?
        let coverage: Coverage?
        let claimAmount: Fiat?
        let estimatedExpenses: Double?
        let incidentDate: Date?
        let dateCreated: Date?
        let state: ClaimState?
        let reimbursement: Double?
        let paymentFinishedDate: Date?
        let datePayToJoin: Date?

        let claimID: Int?

        enum CodingKeys: String, CodingKey {
            case userID = "UserId"
            case avatar = "Avatar"
            case title = "Title"

            case name = "Name"
            case model = "Model"
            case year = "Year"
            case smallPhoto = "SmallPhoto"
            case risk = "Risk"
            case claimLimit = "ClaimLimit"

            case deductible = "Deductible"
            case bigPhotos = "BigPhotos"
            case smallPhotos = "SmallPhotos"
            case coverage = "Coverage"
            case claimAmount = "ClaimAmount"
            case estimatedExpenses = "EstimatedExpenses"
            case incidentDate = "IncidentDate"
            case dateCreated = "DateCreated"
            case state = "State"
            case reimbursement = "Reimbursement"
            case paymentFinishedDate = "DatePaymentFinished"
            case datePayToJoin = "DatePayToJoin"
            case claimID = "ClaimId"
        }

    }
    
}
