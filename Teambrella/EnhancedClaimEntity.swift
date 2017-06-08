//
//  EnhancedClaimEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Temporary simplified version of Claim enhanced entity. It manages json inside and provides necessary getters
 
 It is made so for faster development
 */
struct EnhancedClaimEntity: EntityLike {
    private var json: JSON
    
    var description: String { return "EnhancedClaimEntity id: \(id)" }
    
    init(json: JSON) {
        self.json = json
    }
    
    // MARK: Getters
    var id: String { return json["Id"].stringValue }
    var lastUpdated: Int64 { return json["LastUpdated"].int64Value }
    
    var basicPart: JSON { return json["BasicPart"] }
    var votingPart: JSON { return json["VotingPart"] }
    var discussionPart: JSON { return json["DiscussionPart"] }
    
    var hasVotingPart: Bool { return votingPart.dictionary != nil }
    
    // MARK: Basic part
    
    var userID: String { return basicPart["UserId"].stringValue }
    var avatar: String { return basicPart["Avatar"].stringValue }
    var name: String { return basicPart["Name"].stringValue }
    var model: String { return basicPart["Model"].stringValue }
    var year: Int { return basicPart["Year"].intValue }
    var smallPhotos: [String] { return basicPart["SmallPhotos"].arrayObject as? [String] ?? [] }
    var largePhotos: [String] { return basicPart["BigPhotos"].arrayObject as? [String] ?? [] }
    var claimAmount: Double { return basicPart["ClaimAmount"].doubleValue }
    var estimatedExpences: Double { return basicPart["EstimatedExpences"].doubleValue }
    var deductible: Double { return basicPart["Deductible"].doubleValue }
    var coverage: Double { return basicPart["Coverage"].doubleValue }
    var incidentDate: Date? { return basicPart["IncidentData"].stringValue.cSharpDate }
    
    // MARK: Voting part
    
    var ratioVoted: Double { return votingPart["RatioVoted"].doubleValue }
    var myVote: Double { return votingPart["MyVote"].doubleValue }
    var proxyVote: Double? { return votingPart["ProxyVote"].double }
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
    
    mutating func update(with json: JSON) {
        try? self.json.merge(with: json)
    }
    
}
