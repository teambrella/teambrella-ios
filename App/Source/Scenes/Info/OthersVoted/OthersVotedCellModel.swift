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

struct OthersVotedCellModel {
    let avatar: Avatar
    let name: String
    let subtitle: String
    let subtitleValue: String
    let value: String
    
    init(voter: Voter, isClaim: Bool) {
        avatar = voter.avatar
        name = voter.name
        subtitle = "Info.OthersVoted.Cell.Weight".localized
        subtitleValue = voter.weightCombined.flatMap { String(format: "%.2f", $0) } ?? "..."
        if let vote = voter.vote {
            value = isClaim ? ClaimVote(vote).stringRounded : String(format: "%.2f", vote)
        } else {
            value = "..."
        }
    }
}
