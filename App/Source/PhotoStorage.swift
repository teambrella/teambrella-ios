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

class PhotoStorage {
    enum Constant {
        static let plistName = "StoredPhotos.plist"
    }

    private var storedPhotos: [String: UIImage] = [:]
    private(set) var photosStored: Set<String> = []

    private var path: String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }

    var url: URL? { return URL(string: path + "/" + Constant.plistName) }

    init() {
        if let dict = try? loadDict() {
            storedPhotos = dict
        }
    }

    func containsPhoto(name: String) -> Bool {
        return photosStored.contains(name)
    }

    func add(photo: UIImage, name: String) {
        storedPhotos[name] = photo
        photosStored.insert(name)
        try? store(photo: photo, name: name)
    }

    func removePhoto(name: String) {
        storedPhotos[name] = nil
        photosStored.remove(name)
        try? removeStoredPhoto(name: name)
    }

    // MARK: Private

    private func store(photo: UIImage, name: String) throws {
        var dict = try loadDict()
        dict[name] = photo
        save(dict: dict)
    }

    private func loadDict() throws -> [String: UIImage] {
        var dict: [String: UIImage] = [:]
        guard let url = self.url else { return dict }

        if FileManager.default.fileExists(atPath: url.absoluteString) {
            let fileData = try Data(contentsOf: url)
            dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? [String: UIImage] ?? [:]
        }

        return dict
    }

    private func save(dict: [String: UIImage]) {
        guard let url = url else { return }

        NSKeyedArchiver.archiveRootObject(dict, toFile: url.path)
    }

    private func removeStoredPhoto(name: String) throws {
        var dict = try loadDict()
        dict[name] = nil
        save(dict: dict)
    }

}
