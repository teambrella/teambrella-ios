//
//  TeammateBasicInfo.swift
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
import SwiftyJSON

struct TeammateBasicInfo {
    let id: String
    let teamID: Int
    
    let avatar: String
    let name: String
    let city: String
    let facebook: String
    
    let isProxiedByMe: Bool
    var isMyProxy: Bool
    let role: TeammateType
    let state: TeammateState
    
    let maritalStatus: MaritalStatus
    
    let risk: Double
    let averageRisk: Double
    let totallyPaidAmount: Double
    let coversMeAmount: Double
    let iCoverThemAmount: Double
    
    let dateJoined: Date?
    
    init(json: JSON) {
        id = json["UserId"].stringValue
        teamID = json["TeamId"].intValue
        avatar = json["Avatar"].stringValue
        name = json["Name"].stringValue
        city = json["City"].stringValue
        facebook = json["FacebookUrl"].stringValue
        isProxiedByMe = json["AmIProxy"].boolValue
        isMyProxy = json["IsMyProxy"].boolValue
        role = TeammateType(rawValue: json["Role"].intValue) ?? .regular
        state = TeammateState(rawValue: json["State"].intValue) ?? .joinVoting
        maritalStatus = MaritalStatus(rawValue: json["MaritalStatus"].intValue) ?? .unknown
        risk = json["Risk"].doubleValue
        averageRisk = json["AverageRisk"].doubleValue
        totallyPaidAmount = json["TotallyPaidAmount"].doubleValue
        coversMeAmount = json["TheyCoverMeAmount"].doubleValue
        iCoverThemAmount = json["ICoverThemAmount"].doubleValue
        
        dateJoined = Formatter.teambrella.date(from: json["DateJoined"].stringValue)
    }
}
