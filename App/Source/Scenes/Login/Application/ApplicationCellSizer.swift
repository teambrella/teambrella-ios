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

import CoreGraphics
import Foundation

struct ApplicationCellSizer {
    /// collection view size
    let size: CGSize
    /// horizontal offset from collection view to cell (will be applied to both sides)
    let offset: CGFloat
    
    var defaultWidth: CGFloat { return size.width - offset * 2 }
    
    var titleCellSize: CGSize {
        return CGSize(width: defaultWidth, height: 60)
    }
    
    var inputCellSize: CGSize {
        return CGSize(width: defaultWidth, height: 80)
    }
    
    var actionCellSize: CGSize {
        return CGSize(width: defaultWidth, height: 80)
    }
    
    var termsAndConditionsSize: CGSize {
        return CGSize(width: defaultWidth, height: 80)
    }
    
    var headerSize: CGSize {
        return CGSize(width: size.width, height: 160)
    }
    
    func cellSize(model: ApplicationCellModel) -> CGSize {
        switch model {
        case is ApplicationTitleCellModel:
            return titleCellSize
        case is ApplicationInputCellModel:
            return inputCellSize
        case is ApplicationActionCellModel:
            return actionCellSize
        case is ApplicationTermsAndConditionsCellModel:
            return termsAndConditionsSize
        default:
            return .zero
        }
    }
    
}
