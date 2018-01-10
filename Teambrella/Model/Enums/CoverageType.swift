//
//  CoverageType.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.

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

enum CoverageType: Int, Decodable {
    // in use
    case other                        = 0
    case bicycle                      = 40
    case carCollisionDeductible       = 100
    case petDog                       = 240
    case petCat                       = 241
    
    // reserved
    case carCollision                 = 101
    case carComprehensive             = 102
    case thirdParty                   = 103
    case carCollisionAndComprehensive = 104
    case drone                        = 140
    case mobile                       = 200
    case homeAppliances               = 220
    case unemployment                 = 260
    case healthDental                 = 280
    case healthOther                  = 290
    case businessBees                 = 400
    case businessCrime                = 440
    case businessLiability            = 460
    
    var localizedCoverageObject: String {
        let key = "General.CoverageObject.\(self)"
        let localized = key.localized
        return key != localized ? localized : "General.CoverageObject.other".localized
    }
    
    var localizedCoverageType: String {
        let key = "General.CoverageType.\(self)"
        let localized = key.localized
        return key != localized ? localized : "General.CoverageType.other".localized
    }
    
    init(decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = CoverageType(rawValue: value) ?? .other
    }
    
}
