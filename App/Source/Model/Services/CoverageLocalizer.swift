//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

struct CoverageLocalizer {
    private let type: CoverageType

    init(type: CoverageType) {
        self.type = type
    }
    
    func paidClaimText() -> String {
        switch type {
        case .petCat,
             .petDog:
            return "Team.Chat.ClaimPaid.ShareText.pets".localized
        case .carComprehensive,
             .carCollision,
             .carCollisionAndComprehensive,
             .carCollisionDeductible:
            return "Team.Chat.ClaimPaid.ShareText.car".localized
        case .bicycle:
            return "Team.Chat.ClaimPaid.ShareText.bike".localized
        default:
            return "Team.Chat.ClaimPaidCell.text".localized
        }
    }

    func yearsString(year: Year?) -> String {
        guard let year = year else { return "" }
        
        // for pets we use "pet name, 2 y.o." format
        switch type {
        case .petCat, .petDog:
            switch year.value {
            case ...0:
                return "Team.TearsOld.lessThanAYear".localized
            default:
                return "Team.YearsOld.years_format".localized(year.yearsSinceNow)
            }
        default:
            return "\(year)"
        }
    }

    func myCoveredObject() -> String {
        let owner: String
        if type == .petCat || type == .petDog {
            owner = "General.posessiveFormat.my.female".localized
        } else {
            owner = "General.posessiveFormat.my.male".localized
        }
        return "General.unitedFormat.my".localized(owner, coveredObject)
    }

    var coveredObject: String {
        let key = "General.CoverageObject.\(type)"
        let localized = key.localized
        return key != localized ? localized : "General.CoverageObject.other".localized
    }

    var coverageType: String {
        let key = "General.CoverageType.\(type)"
        let localized = key.localized
        return key != localized ? localized : "General.CoverageType.other".localized
    }

}
