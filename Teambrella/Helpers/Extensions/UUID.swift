//
//  UUID.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.04.17.

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

extension UUID {
    var bytes: [UInt8] {
        let str = self.uuidString.components(separatedBy: "-").joined()
        return str.split(by: 2).flatMap { UInt8($0, radix: 16) }
    }
}

extension UUID: Comparable {
    public static func < (lhs: UUID, rhs: UUID) -> Bool {
        let lBytes = lhs.bytes
        let rBytes = rhs.bytes
        for (idx, l) in lBytes.enumerated() where l != rBytes[idx] {
            return l < rBytes[idx] ? true : false
        }
        return false
    }
}
