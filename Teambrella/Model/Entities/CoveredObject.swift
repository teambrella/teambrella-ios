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

struct CoveredObject: Decodable {
    let smallPhotos: [String]
    let largePhotos: [String]
    let model: String
    let year: Int
    let subType: String?
    let keyWords: String?
    let spayed: Bool
    let claimLimit: Double
    let claimCount: Int

    private let claimID: Int?

    var singleClaimID: Int? {
        guard let claimID = claimID else { return nil }

        // Patch to emulate null behaviour. Unfortunately server returns "0" instead of null in this case
        return claimID != 0 ? claimID : nil
    }

    enum CodingKeys: String, CodingKey {
        case smallPhotos = "SmallPhotos"
        case largePhotos = "BigPhotos"
        case model = "Model"
        case year = "Year"
        case subType = "SubType"
        case keyWords = "KeyWords"
        case spayed = "Spayed"
        case claimLimit = "ClaimLimit"
        case claimCount = "ClaimCount"
        case claimID = "OneClaimId"
    }
    
}
