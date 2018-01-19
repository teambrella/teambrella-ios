//
//  ClaimEntity.swift
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

struct ClaimEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case lastUpdated = "LastUpdated"
        case smallPhoto = "SmallPhoto"
        case avatar = "Avatar"
        case model = "Model"
        case name = "Name"
        case state = "State"
        case claimAmount = "ClaimAmount"
        case reimbursement = "Reimbursement"
//        case votingRes = "VotingRes_Crypto"
//        case paymentRes = "PaymentRes_Crypto"
        case proxyAvatar = "ProxyAvatar"
        case proxyName = "ProxyName"
        case myVote = "MyVote"
    }
    
    var id: Int
    var lastUpdated: Int64
    
    var smallPhoto: String
    var avatar: String
    var model: String
    var name: String
    var state: ClaimState
    var claimAmount: Double
    var reimbursement: Double
//    var votingRes: Double?
//    var paymentRes: Double
    var myVote: Double?
    
    var proxyAvatar: String?
    var proxyName: String?
    
    var description: String {
        return "\(#file) \(id)"
    }

}
