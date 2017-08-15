//
//  BlockchainDateFormatter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.

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
import SwiftyJSON

class BlockchainDateFormatter: DateFormatter {
    override init() {
        super.init()
       setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
         dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func date(from json: JSON, key: String) -> Date? {
        return date(from: json[key].stringValue)
    }
    
    func nsDate(from json: JSON, key: String) -> NSDate? {
        return date(from: json, key: key) as NSDate?
    }
    
}
