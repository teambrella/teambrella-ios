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

protocol BasicPart {
    var userID: String { get }
    var avatar: String { get }
    
    init(json: JSON)
}

struct BasicPartDiscussionConcrete: BasicPart {
    let userID: String
    let avatar: String
    let title: String
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        avatar = json["Avatar"].stringValue
        title = json["Title"].stringValue
    }
}

struct BasicPartTeammateConcrete: BasicPart {
    let userID: String
    let name: Name
    let avatar: String
    let model: String
    let year: Int
    let smallPhoto: String
    
    let risk: Double?
    let claimLimit: Double?
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        name = Name(fullName: json["Name"].stringValue)
        avatar = json["Avatar"].stringValue
        model = json["Model"].stringValue
        year = json["Year"].intValue
        smallPhoto = json["SmallPhoto"].stringValue
        
        risk = json["Risk"].double
        claimLimit = json["ClaimLimit"].double
    }
}

struct BasicPartClaimConcrete: BasicPart {
    let userID: String
    let name: Name
    let avatar: String
    let model: String
    let year: Int
    var smallPhoto: String 
    
    let deductible: Double
    let bigPhotos: [String]
    let smallPhotos: [String]
    let coverage: Double
    let claimAmount: Double
    let estimatedExpenses: Double
    let incidentDate: Date?
    let state: ClaimState
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        name = Name(fullName: json["Name"].stringValue)
        avatar = json["Avatar"].stringValue
        model = json["Model"].stringValue
        year = json["Year"].intValue
        
        deductible = json["Deductible"].doubleValue
        bigPhotos = json["BigPhotos"].arrayObject as? [String] ?? []
        smallPhotos = json["SmallPhotos"].arrayObject as? [String] ?? []
        smallPhoto = json["SmallPhoto"].stringValue
        coverage = json["Coverage"].doubleValue
        claimAmount = json["ClaimAmount"].doubleValue
        estimatedExpenses = json["EstimatedExpenses"].doubleValue
        incidentDate = Formatter.teambrella.date(from: json["IncidentDate"].stringValue)
        state = ClaimState(rawValue: json["State"].intValue) ?? .voting
    }
    
}

struct BasicPartFactory {
    static func basicPart(from json: JSON) -> BasicPart? {
        var json = json
        if json["BasicPart"].exists() { json = json["BasicPart"] }
        
        if json["ClaimAmount"].exists() {
            return BasicPartClaimConcrete(json: json)
        } else if json["Title"].exists() {
            return BasicPartDiscussionConcrete(json: json)
        } else if json["UserId"].exists() {
            return BasicPartTeammateConcrete(json: json)
        } else {
            return nil
        }
    }
    
}
