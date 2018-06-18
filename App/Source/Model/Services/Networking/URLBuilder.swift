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

class URLBuilder {
    #if SURILLA
    let isLocalServer = true
    let siteURL: String = "http://surilla.com"
    #else
    let isLocalServer = false
    let siteURL: String = "https://teambrella.com"
    #endif
    
    func url(for string: String, parameters: [String: String]?) -> URL? {
        var urlComponents = URLComponents(string: urlString(string: string))
        if let parameters = parameters {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters {
                guard let key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        continue
                }
                
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents?.queryItems = queryItems
        }
        return urlComponents?.url
    }
    
    func urlString(string: String) -> String {
        if string.hasPrefix(siteURL) {
            return string
        }
        if string.hasPrefix("/") {
            return siteURL + string
        }
        return siteURL + "/" + string
    }
    
    func url(string: String) -> URL? {
        return URL(string: urlString(string: string))
    }

    func urlString(claimID: Int, teamID: Int) -> String {
        return"\(siteURL)/claim/\(teamID)/\(claimID)"
    }
    
}

import CoreGraphics

extension URLBuilder {
    func avatarURLstring(for string: String,
                         width: CGFloat? = 128,
                         crop rect: CGRect? = CGRect(x: 0, y: 0, width: 128, height: 128)) -> String {
        var urlString = siteURL + string
        if let width = width {
            let rect = rect ?? CGRect(x: 0, y: 0, width: width, height: width)
            urlString += "?width=\(width)&crop=\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height)"
        }
        return urlString
    }
}
