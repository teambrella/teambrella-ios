//
//  CoverageEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.

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
