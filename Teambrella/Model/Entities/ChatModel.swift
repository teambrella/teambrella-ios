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
import SwiftyJSON

struct ChatModel {
    let lastUpdated: Int64
    let discussion: JSON
    //let lastRead: Int64
    let chat: [ChatEntity]
    let basicPart: BasicPart?
    let teamPart: TeamPart?
    let votingPart: VotingPart?

    let claimID: Int
    
    let title: String
    
    init(json: JSON, chat: [ChatEntity]) {
        lastUpdated = json["LastUpdated"].int64Value
        discussion = json["DiscussionPart"]
        self.chat = chat
        basicPart = BasicPart(json: json["BasicPart"])
        teamPart = TeamPart(json: json["TeamPart"])
        votingPart = VotingPart(json: json["VotingPart"])
        title = json["Title"].stringValue
        claimID = json["Id"].intValue
    }
    
    // Discussion Part
    var topicID: String { return discussion["TopicId"].stringValue }
    var lastRead: Int64 { return discussion["LastRead"].int64Value }
    var isMuted: Bool? { return discussion["IsMuted"].bool }

    struct VotingPart {
        let remainingMinutes: Int
        let proxyName: String?
        let proxyAvatar: String?
        let myVote: Double?

        let riskVoted: Double?
        let ratioVoted: Double?

        let otherCount: Int?
        let otherAvatars: [String]?

        init(json: JSON) {
            remainingMinutes = json["RemainedMinutes"].intValue
            proxyName = json["ProxyName"].string
            proxyAvatar = json["ProxyAvatar"].string
            myVote = json["MyVote"].double

            ratioVoted = json["RatioVoted"].double
            otherCount = json["OtherCount"].intValue
            otherAvatars = json["OtherAvatars"].arrayObject as? [String]

            riskVoted = json["RiskVoted"].double
        }
    }

    struct BasicPart: Decodable {
        let userID: String
        let avatar: String
        let title: String

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

        init?(json: JSON) {
            guard !json.isEmpty else { return nil }

            userID = json["UserId"].stringValue
            avatar = json["Avatar"].stringValue
            title = json["Title"].stringValue

            model = json["Model"].string
            year = json["Year"].int
            smallPhoto = json["SmallPhoto"].string
            risk = json["Risk"].double
            claimLimit = json["ClaimLimit"].double

            name = Name(fullName: json["Name"].stringValue)
            deductible = json["Deductible"].double
            bigPhotos = json["BigPhotos"].arrayObject as? [String]
            smallPhotos = json["SmallPhotos"].arrayObject as? [String]
            coverage = json["Coverage"].double.map { Coverage($0) }
            claimAmount = json["ClaimAmount"].double
            estimatedExpenses = json["EstimatedExpenses"].double
            incidentDate = json["IncidentDate"].string.flatMap { Formatter.teambrella.date(from: $0) }
            state = json["State"].int.flatMap { ClaimState(rawValue: $0) }
            reimbursement = json["Reimbursement"].double
        }
    }
    
}
