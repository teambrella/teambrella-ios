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

struct NameComponent: CustomStringConvertible {
    let fragments: [String]
    
    var hasPrefix: Bool
    var entire: String { return fragments.joined() }
    var description: String { return entire }
}

struct Name: Codable {
    static var empty: Name { return Name(fullName: "") }
    
    let components: [NameComponent]
    let hasLastName: Bool

    var isEmpty: Bool { return entire == "" }
    
    var first: String { return components.first?.entire ?? "" }
    var last: String? { return hasLastName ? components.last?.entire : nil }
    var entire: String {
        var result = ""
        let count = components.count
        for (idx, component) in components.enumerated() {
            result += component.entire
            if count > 1 && idx < count - 1 {
                result += " "
            }
        }
        return result
    }
    
    var short: String {
        let count = components.count > 1 ? 2 : components.count
        let shortened = components[..<count]
        var result = ""
        for item in shortened {
            if result != "" { result += " " }
            result += item.entire
        }
        return result
    }
    
    init(from decoder: Decoder) throws {
        let name = try decoder.singleValueContainer().decode(String.self)
        self.init(fullName: name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(entire)
    }
    
    init(fullName: String) {
        let subEntities = fullName.split(separator: " ").map { String($0) }
        var fragments: [String] = []
        var components: [NameComponent] = []
        var hasPrefix = false
        for entity in subEntities {
            let isCapitalized = entity == entity.capitalized
            let hasApostrophe = entity.contains("'")
            if !isCapitalized && fragments.isEmpty {
                hasPrefix = true
            }
            if !fragments.isEmpty {
                fragments.append(" ")
            }
            fragments.append(entity)
            
            if isCapitalized || hasApostrophe {
                let component = NameComponent(fragments: fragments, hasPrefix: hasPrefix)
                components.append(component)
                fragments = []
                hasPrefix = false
            }
        }
        
        // in case the name consists of one word from lowercase letter
        if components.isEmpty {
            let component = NameComponent(fragments: [fullName], hasPrefix: false)
            components.append(component)
        }
        
        self.components = components
        hasLastName = components.count > 1
    }
    
}

extension Name: Comparable {
    static func == (lhs: Name, rhs: Name) -> Bool {
        return lhs.entire == rhs.entire
    }
    
    static func < (lhs: Name, rhs: Name) -> Bool {
        return lhs.entire < rhs.entire
    }
}
