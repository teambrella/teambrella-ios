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
    let prototype: CurrencyLike & CurrencyTransformable
    let value: Decimal
    
    func currencyAdding(_ other: Currency) -> Currency? {
        guard let rate = other.prototype.rate(to: prototype) else { return nil }
        
        let newValue = other.value * rate + value
        return Currency(prototype: prototype, value: newValue)
    }
}

extension Currency: Comparable {
    static func < (lhs: Currency, rhs: Currency) -> Bool {
        guard let rate = lhs.prototype.rate(to: rhs.prototype) else { return false }
        
        return lhs.value * rate < rhs.value
    }
    
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        guard let rate = lhs.prototype.rate(to: rhs.prototype) else { return false }
        
        return abs(lhs.value * rate - rhs.value) < 0.0000000000000001
    }
}
