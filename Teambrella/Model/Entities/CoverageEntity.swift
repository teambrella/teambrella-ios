//
//  CoverageEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CoverageEntity {
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var coverage: Double { return json["Coverage"].doubleValue }
    var nextCoverage: Double { return json["NextCoverage"].doubleValue }
    var daysToNextCoverage: Int { return json["DaysToNextCoverage"].intValue }
    var claimLimit: Double { return json["ClaimLimit"].doubleValue }
    var deductibleAmount: Double { return json["DeductibleAmount"].doubleValue }
}
