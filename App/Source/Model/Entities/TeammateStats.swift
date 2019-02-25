//
//  TeammateStats.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.

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

struct TeammateStats: Decodable {
    let weight: Double
    let proxyRank: Double
    let decisionFrequency: Double
    let discussionFrequency: Double
    let votingFrequency: Double
    let claimsVoteAsTeamOrBetter: Double
    let claimsVoteAsTeam: Double
    let risksVoteAsTeamOrBetter: Double
    let risksVoteAsTeam: Double

    enum CodingKeys: String, CodingKey {
        case weight = "Weight"
        case proxyRank = "ProxyRank"
        case decisionFrequency = "DecisionFreq"
        case discussionFrequency = "DiscussionFreq"
        case votingFrequency = "VotingFreq"
        case claimsVoteAsTeamOrBetter = "ClaimsVoteAsTeamOrBetter"
        case claimsVoteAsTeam = "ClaimsVoteAsTeam"
        case risksVoteAsTeamOrBetter = "RisksVoteAsTeamOrBetter"
        case risksVoteAsTeam = "RisksVoteAsTeam"
    }
}
