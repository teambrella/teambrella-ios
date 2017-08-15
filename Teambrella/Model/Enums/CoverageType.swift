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

enum CoverageType: Int {
    case other                        = 0
    case bicycle                      = 40
    case carCollisionDeductable       = 100
    case carCollision                 = 101
    case carComprehensive             = 102
    case thirdParty                   = 103
    case carCollisionAndComprehensive = 104
    case drone                        = 140
    case mobile                       = 200
    case homeAppliances               = 220
    case pet                          = 240
    case unemployment                 = 260
    case healthDental                 = 280
    case healthOther                  = 290
    case businessBees                 = 400
    case businessCrime                = 440
    case businessLiability            = 460
}
