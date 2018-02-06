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

struct ChatModel: Decodable {
    let lastUpdated: Int64
    let discussion: DiscussionPart

    let basic: BasicPart?
    let team: TeamPart?
    let voting: VotingPart?

    let id: Int?
    let lastRead: Int64?
    let topicID: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "LastUpdated"
        case discussion = "DiscussionPart"
        case basic = "BasicPart"
        case team = "TeamPart"
        case voting = "VotingPart"
        case id = "Id"
        case title = "Title"
        case lastRead = "LastRead"
        case topicID = "TopicId"
    }

    struct DiscussionPart: Decodable {
        let isMuted: Bool?
        let lastRead: Int64
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
        let remainingMinutes: Int
        let proxyName: String?
        let proxyAvatar: String?
        let myVote: Double?

        let riskVoted: Double?
        let ratioVoted: ClaimVote?

        let otherCount: Int?
        let otherAvatars: [String]?

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
        let year: Int?
        let smallPhoto: String?
        let risk: Double?
        let claimLimit: Double?

        let name: Name?
        let deductible: Double?
        let bigPhotos: [String]?
        let smallPhotos: [String]?
        let coverage: Coverage?
        let claimAmount: Double?
        let estimatedExpenses: Double?
        let incidentDate: Date?
        let state: ClaimState?
        let reimbursement: Double?

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
            case state = "State"
            case reimbursement = "Reimbursement"
        }

    }
    
}
