//
//  TextAdapter.swift
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
import SwiftSoup

struct TextAdapter {
    func parsedHTML(string: String) -> String {
        do {
            let doc: Document = try SwiftSoup.parse(string)
            return try doc.text()
        } catch Exception.Error(let type, let message) {
            log("\(type) --> " + message, type: .error)
        } catch {
            log("error", type: .error)
        }
        log("Falling back to original message", type: .error)
        return string
    }
}
