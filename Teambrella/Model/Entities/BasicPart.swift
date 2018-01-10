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

struct BasicPartDiscussionConcrete: BasicPart, Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case avatar = "Avatar"
        case title = "Title"
    }
    
    let userID: String
    let avatar: String
    let title: String
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        avatar = json["Avatar"].stringValue
        title = json["Title"].stringValue
    }
}

struct BasicPartTeammateConcrete: BasicPart, Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case name = "Name"
        case avatar = "Avatar"
        case model = "Model"
        case year = "Year"
        case smallPhoto = "SmallPhoto"
        case risk = "Risk"
        case claimLimit = "ClaimLimit"
    }
    
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

struct BasicPartClaimConcrete: BasicPart, Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case name = "Name"
        case avatar = "Avatar"
        case model = "Model"
        case year = "Year"
        case smallPhoto = "SmallPhoto"
        case deductible = "Deductible"
        case bigPhotos = "BigPhotos"
        case smallPhotos = "SmallPhotos"
        case coverage = "Coverage"
        case claimAmount = "ClaimAmount"
        case estimatedExpenses = "EstimatedExpenses"
        case incidentDate = "IncidentDate"
        case state = "State"
        case reimbursement = "Reimbursement"
        case claimLimit = "ClaimLimit"
    }
    
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
    
    let reimbursement: Double?
    let claimLimit: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .incidentDate)
        incidentDate = Formatter.teambrella.date(from: dateString)
        
        userID = try container.decode(String.self, forKey: .userID)
        name = try container.decode(Name.self, forKey: .name)
        avatar = try container.decode(String.self, forKey: .avatar)
        model = try container.decode(String.self, forKey: .model)
        year = try container.decode(Int.self, forKey: .year)
        smallPhoto = try container.decode(String.self, forKey: .smallPhoto)
        deductible = try container.decode(Double.self, forKey: .deductible)
        bigPhotos = try container.decode([String].self, forKey: .bigPhotos)
        smallPhotos = try container.decode([String].self, forKey: .smallPhotos)
        coverage = try container.decode(Double.self, forKey: .coverage)
        claimAmount = try container.decode(Double.self, forKey: .claimAmount)
        estimatedExpenses = try container.decode(Double.self, forKey: .estimatedExpenses)
        state = try container.decode(ClaimState.self, forKey: .state)
        reimbursement = try container.decodeIfPresent(Double.self, forKey: .reimbursement)
        claimLimit = try container.decodeIfPresent(Double.self, forKey: .claimLimit)
    }
    
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
        
        reimbursement = json["Reimbursement"].double
        claimLimit = json["ClaimLimit"].double
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
