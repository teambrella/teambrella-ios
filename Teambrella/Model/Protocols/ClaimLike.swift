//
//  ClaimLike.swift
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

protocol ClaimLike: EntityLike {
    var smallPhoto: String { get }
    var avatar: String { get }
    var model: String { get }
    var name: String { get }
    var state: ClaimState { get }
    var claimAmount: Double { get }
    var reimbursement: Double { get }
    var votingResBTC: Double { get }
    var paymentResBTC: Double { get }
    
    var proxyAvatar: String? { get }
    var proxyName: String? { get }
    
}
