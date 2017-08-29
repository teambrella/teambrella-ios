//
//  XIBInitableCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

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

protocol XIBInitableCell {
    static var nib: UINib { get }
    static var cellID: String { get }
}

extension XIBInitableCell where Self: UICollectionReusableView {
    static var nib: UINib { return UINib(nibName: "\(self)", bundle: nil) }
    static var cellID: String { return "\(self)" }
}

extension XIBInitableCell where Self: UITableViewCell {
    static var nib: UINib { return UINib(nibName: "\(self)", bundle: nil) }
    static var cellID: String { return "\(self)" }
}
