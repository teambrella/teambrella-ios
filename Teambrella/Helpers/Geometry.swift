//
//  Geometry.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.05.17.

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

import CoreGraphics
import Foundation

func radiansFrom(degrees: CGFloat) -> CGFloat { return degrees * CGFloat.pi / 180 }

func degreesFrom(radians: CGFloat) -> CGFloat { return radians * 180 / CGFloat.pi }

/// converts angle counting from North rather than from 0
func compass(degrees: CGFloat) -> CGFloat { return compass(radians: radiansFrom(degrees: degrees)) }

/// converts angle counting from North rather than from 0
func compass(radians: CGFloat) -> CGFloat { return radians - CGFloat.pi * 0.5 }

struct Circle {
    let radius: CGFloat
    let center: CGPoint
    
    /// returns point on circumference by the given angle clockwise in radians
    func circumferencePoint(radians: CGFloat) -> CGPoint {
        return CGPoint(x: center.x + radius * cos(radians), y: center.y + radius * sin(radians))
    }
}
