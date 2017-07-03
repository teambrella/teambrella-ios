//
//  RiskScaleEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct RiskScaleEntity {
    struct Teammate {
        let id: String
        let avatar: String
        let risk: Double
        
        init(json: JSON) {
            id = json["UserId"].stringValue
            avatar = json["Avatar"].stringValue
            risk = json["Risk"].doubleValue
        }
    }
    
    struct Range {
        let left: Double
        let right: Double
        let count: Int
        let teammates: [Teammate]
        
        init(json: JSON) {
            left = json["LeftRange"].doubleValue
            right = json["RightRange"].doubleValue
            count = json["Count"].intValue
            teammates = json["TeammatesInRange"].arrayValue.flatMap { Teammate(json: $0) }
        }
    }
    
    let ranges: [Range]
    let averageRisk: Double
    let coversIfMin: Double
    let coversIf1: Double
    let coversIfMax: Double
    let myRisk: Double
    
    init?(json: JSON) {
        guard json.exists() else { return nil }
        
        ranges = json["Ranges"].arrayValue.flatMap { Range(json: $0) }
        averageRisk = json["AverageRisk"].doubleValue
        coversIfMin = json["HeCoversMeIf02"].doubleValue
        coversIf1 = json["HeCoversMeIf1"].doubleValue
        coversIfMax = json["HeCoversMeIf499"].doubleValue
        myRisk = json["MyRisk"].doubleValue
    }
    
}
