//
//  EnhancedClaimEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.

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

struct ClaimEntityLarge: Decodable, CustomStringConvertible {
    let id: Int
    let lastUpdated: Int64

    let basic: BasicPart
    var discussion: TopicEntity
    var voting: VotingPart?
    var voted: VotingPart?
    let team: TeamPart

    var description: String { return "ClaimEntityLarge: \(id)" }

    mutating func update(with voteUpdate: ClaimVoteUpdate) {
        voting = voteUpdate.voting
        discussion.update(with: voteUpdate.discussion)
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case lastUpdated = "LastUpdated"
        case basic = "BasicPart"
        case voting = "VotingPart"
        case voted = "VotedPart"
        case discussion = "DiscussionPart"
        case team = "TeamPart"
    }

    struct BasicPart: Decodable {
        let userID: String
        let avatar: String
        let name: String
        let model: String
        let year: Year
        let smallPhotos: [String]
        let largePhotos: [String]
        let claimAmount: Fiat
        let estimatedExpenses: Double
        let deductible: Double
        let coverage: Double
        let incidentDate: Date

        enum CodingKeys: String, CodingKey {
            case userID = "UserId"
            case avatar = "Avatar"
            case name = "Name"
            case model = "Model"
            case year = "Year"
            case smallPhotos = "SmallPhotos"
            case largePhotos = "BigPhotos"
            case claimAmount = "ClaimAmount"
            case estimatedExpenses = "EstimatedExpenses"
            case deductible = "Deductible"
            case coverage = "Coverage"
            case incidentDate = "IncidentDate"
        }

    }

    struct VotingPart: Decodable {
        let ratioVoted: ClaimVote
        let myVote: ClaimVote?
        let proxyAvatar: Avatar?
        let proxyName: Name?
        let otherAvatars: [Avatar]
        let otherCount: Int
        let minutesRemaining: Int

        enum CodingKeys: String, CodingKey {
            case ratioVoted = "RatioVoted"
            case myVote = "MyVote"
            case proxyAvatar = "ProxyAvatar"
            case proxyName = "ProxyName"
            case otherAvatars = "OtherAvatars"
            case otherCount = "OtherCount"
            case minutesRemaining = "RemainedMinutes"
        }
        
    }

}
