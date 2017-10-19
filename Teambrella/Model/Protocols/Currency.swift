//
/* Copyright(C) 2017 Teambrella, Inc.
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

struct Currency {
    let prototype: CurrencyLike
    let value: Decimal
    
    func currencyAdding(_ other: Currency) -> Currency? {
        guard let transformable = prototype as? CurrencyTransformable,
            let otherTransformable = other.prototype as? CurrencyTransformable,
            let rate = transformable.rate(to: otherTransformable) else { return nil }
        
        return Currency(prototype: prototype, value: value * Decimal(rate))
    }
}

extension Currency: Comparable {
    static func <(lhs: Currency, rhs: Currency) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
        
        return lhs.value < rhs.value
    }
    
    static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return type(of: lhs) == type(of: rhs) && lhs.value == rhs.value
    }
}
