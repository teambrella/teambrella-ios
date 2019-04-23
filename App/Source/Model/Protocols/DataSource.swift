//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

protocol SingleItemDataSource: Loadable {
    associatedtype Item
    
    var item: Item? { get }
    var isItemLoaded: Bool { get }
}

protocol FlatDataSource: Countable {
    associatedtype Item
    
    var items: [Item] { get }
    subscript(indexPath: IndexPath) -> Item { get }
}

protocol SectionedDataSource: Countable, Loadable {
    associatedtype Item
    
    var items: [[Item]] { get }
    var sections: Int { get }
    
    func items(in section: Int) -> Int
    subscript(indexPath: IndexPath) -> Item { get }
}

protocol Countable {
    var count: Int { get }
    var isEmpty: Bool { get }
}

protocol Updateable {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
}

protocol Loadable: Updateable {
     var isLoading: Bool { get }
    
     func loadData()
}

protocol StandardDataSource: FlatDataSource, Loadable {
    
}

extension Countable {
    // swiftlint:disable:next empty_count
    var isEmpty: Bool { return count == 0 }
}

extension FlatDataSource {
    var count: Int { return self.items.count }
    
    subscript(indexPath: IndexPath) -> Item {
        return items[indexPath.row]
    }
}

extension SectionedDataSource {
    var count: Int { return self.items.reduce(0) { $0 + $1.count } }
    var sections: Int { return self.items.count }
    
    func items(in section: Int) -> Int {
        return items[section].count
    }
    
    subscript(indexPath: IndexPath) -> Item {
        return items[indexPath.section][indexPath.row]
    }
}

extension SingleItemDataSource {
    var isItemLoaded: Bool { return item != nil }
}
