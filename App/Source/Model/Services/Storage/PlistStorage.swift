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

struct PlistStorage {
    private var url: URL? { return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first }
    
    var userURL: URL? {
        guard let userID = service.session?.currentUserID else { return nil }
        guard let url = url?.appendingPathComponent(userID, isDirectory: true) else { return nil }
        
        if FileManager.default.fileExists(atPath: url.path) == false {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }

    /*
    func store(json: JSON, for requestType: TeambrellaRequestType, id: String) {
        guard let path = path(requestType: requestType, id: id) else { return }
        guard let object = json.object as? NSCoding else {
            log("object \(json.object) is not NSCoding compliant", type: .error)
            return
        }
        
        NSKeyedArchiver.archiveRootObject(object, toFile: path)
    }
    
    func retreiveJSON(for requestType: TeambrellaRequestType, id: String) -> JSON? {
        guard let path = path(requestType: requestType, id: id) else { return nil }
        guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: path) else { return nil }
        
        return JSON(object)
    }
    */

    func path(requestType: TeambrellaRequestType, id: String) -> String? {
        let type = requestType.rawValue.replacingOccurrences(of: "/", with: "_")
        return userURL?.appendingPathComponent(type + "-" + id).path
    }
    
    func removeCache() {
        guard let path = userURL?.path else { return }
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
}
