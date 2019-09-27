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

struct CoverageEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case coverage = "Coverage"
        case nextCoverage = "NextCoverage"
        case daysToNextCoverage = "DaysToNextCoverage"
        case claimLimit = "ClaimLimit"
        case nextLimit = "NextLimit"
        case deductibleAmount = "DeductibleAmount"
        case desiredLimit = "DesiredLimit"
        case maxPayment = "MaxPayment"
        case teammatesAtEffLimit = "TeammatesAtEffLimit"
        case teammatesAtLimit = "TeammatesAtLimit"
        case teamClaimLimit = "TeamClaimLimit"
        case wasCoverageSuppressed = "WasCoverageSuppressed"
        case text = "Text"
    }

    var coverage: Ether
    var nextCoverage: Ether
    var daysToNextCoverage: Int
    var deductibleAmount: Ether
    let desiredLimit: Double
    let claimLimit: Double
    let nextLimit: Double
    let maxPayment: Double
    let teammatesAtEffLimit: Int
    let teammatesAtLimit: Int
    let teamClaimLimit: Int?
    let wasCoverageSuppressed: Bool
    let text: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        coverage = try container.decode(Ether.self, forKey: .coverage)
        nextCoverage = try container.decode(Ether.self, forKey: .nextCoverage)
        daysToNextCoverage = try container.decode(Int.self, forKey: .daysToNextCoverage)
        claimLimit = try container.decode(Double.self, forKey: .claimLimit)
        nextLimit = try container.decode(Double.self, forKey: .nextLimit)
        deductibleAmount = try container.decode(Ether.self, forKey: .deductibleAmount)
        desiredLimit = try container.decode(Double.self, forKey: .desiredLimit)
        maxPayment = try container.decode(Double.self, forKey: .maxPayment)
        teammatesAtEffLimit = try container.decode(Int.self, forKey: .teammatesAtEffLimit)
        teammatesAtLimit = try container.decode(Int.self, forKey: .teammatesAtLimit)
        teamClaimLimit = try container.decodeIfPresent(Int.self, forKey: .teamClaimLimit)
        wasCoverageSuppressed = try container.decode(Bool.self, forKey: .wasCoverageSuppressed)
        text = try container.decodeIfPresent(String.self, forKey: .text)
    }

}
