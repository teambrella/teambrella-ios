//
//  CoveredObject.swift
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

struct CoveredObject {
    let smallPhotos: [String]
    let largePhotos: [String]
    let model: String
    let year: Int
    let subType: String
    let keyWords: String
    let spayed: Bool
    let claimLimit: Double
    let claimCount: Int
    let singleClaimID: String?
    
    init(json: JSON) {
        smallPhotos = json["SmallPhotos"].arrayObject as? [String] ?? []
        largePhotos = json["BigPhotos"].arrayObject as? [String] ?? []
        model = json["Model"].stringValue
        year = json["Year"].intValue
        subType = json["SubType"].stringValue
        keyWords = json["KeyWords"].stringValue
        spayed = json["Spayed"].boolValue
        claimLimit = json["ClaimLimit"].doubleValue
        claimCount = json["ClaimCount"].intValue
        // Patch to emulate null behaviour. Unfortunately server returns "0" instead of null in this case
        let claimID = json["OneClaimId"].stringValue
        singleClaimID = claimID != "0" ? claimID : nil
    }
    
}
