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
import SwiftyJSON

/**
 Temporary simplified version of Claim enhanced entity. It manages json inside and provides necessary getters
 
 It is made so for faster development
 */
struct ClaimEntityLarge {
    private var json: JSON
    
    var description: String { return "EnhancedClaimEntity id: \(id)" }
    
    init(json: JSON) {
        self.json = json
    }
    
    // MARK: Getters
    var id: Int { return json["Id"].intValue }
    var lastUpdated: Int64 { return json["LastUpdated"].int64Value }
    
    var basicPart: JSON { return json["BasicPart"] }
    var votingPart: JSON { return json["VotingPart"] }
    var discussionPart: JSON { return json["DiscussionPart"] }
    var teamPart: JSON { return json["TeamPart"] }
    
    var hasVotingPart: Bool { return votingPart.dictionary != nil }
    
    // MARK: Basic part
    
    var userID: String { return basicPart["UserId"].stringValue }
    var avatar: String { return basicPart["Avatar"].stringValue }
    var name: String { return basicPart["Name"].stringValue }
    var model: String { return basicPart["Model"].stringValue }
    var year: Int { return basicPart["Year"].intValue }
    var smallPhotos: [String] { return basicPart["SmallPhotos"].arrayObject as? [String] ?? [] }
    var largePhotos: [String] { return basicPart["BigPhotos"].arrayObject as? [String] ?? [] }
    var claimAmount: Fiat { return Fiat(basicPart["ClaimAmount"].doubleValue) }
    var estimatedExpences: Double { return basicPart["EstimatedExpenses"].doubleValue }
    var deductible: Double { return basicPart["Deductible"].doubleValue }
    var coverage: Double { return basicPart["Coverage"].doubleValue }
    var incidentDate: Date? { return DateFormatter.teambrella.date(from: basicPart["IncidentDate"].stringValue) }
    
    // MARK: Voting part
    
    var ratioVoted: ClaimVote { return ClaimVote(votingPart["RatioVoted"].doubleValue) }
    var myVote: ClaimVote? { return votingPart["MyVote"].double.map { ClaimVote($0)} }
    var proxyVote: ClaimVote? { return votingPart["ProxyVote"].double.map { ClaimVote($0)} }
    var proxyAvatar: String? { return votingPart["ProxyAvatar"].string }
    var proxyName: String? { return votingPart["ProxyName"].string }
    var otherAvatars: [String] { return votingPart["OtherAvatars"].arrayObject as? [String] ?? [] }
    var otherCount: Int { return votingPart["OtherCount"].intValue }
    var minutesRemaining: Int { return votingPart["RemainedMinutes"].intValue }
    
    // MARK: Discussion Part
    
    var topicID: String { return discussionPart["TopicId"].stringValue }
    var originalPostText: String { return discussionPart["OriginalPostText"].stringValue }
    var unreadCount: Int { return discussionPart["UnreadCount"].intValue }
    var minutesinceLastPost: Int { return discussionPart["SinceLastPostMinutes"].intValue }
    var smallPhoto: String { return discussionPart["SmallPhoto"].stringValue }
    var topPosterAvatars: [String] { return discussionPart["TopPosterAvatars"].arrayObject as? [String] ?? [] }
    var posterCount: Int { return discussionPart["PosterCount"].intValue }
    
    // MARK: Team Part
    
    var coverageType: Int { return teamPart["CoverageType"].intValue }
    var currency: String { return teamPart["Currency"].stringValue }
    var teamAccessLevel: Int { return teamPart["TeamAccessLevel"].intValue }
    
    mutating func update(with json: JSON) {
        try? self.json.merge(with: json)
        // because merge of arrays (even if they are equal) adds one to another
        self.json["VotingPart"]["OtherAvatars"] = json["VotingPart"]["OtherAvatars"]
    }
    
}
