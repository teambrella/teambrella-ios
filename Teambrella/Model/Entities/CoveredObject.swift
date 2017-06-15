//
//  CoveredObject.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
