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

import Alamofire
import Foundation

class TimestampFetcher {
    func requestTimestamp(completion: @escaping (Int64, Error?) -> Void) {
        guard let url = URLBuilder().url(string: "me/GetTimestamp") else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case let .success(data):
                do {
                    let result = try JSONDecoder().decode(TimestampReply.self, from: data)
                    completion(result.status.timestamp, nil)
                } catch {
                    completion(0, error)
                }
            case let .failure(error):
                completion(0, error)
            }
        }
    }
    
}

struct TimestampReply: Codable {
    let status: TimestampReplyStatus

    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }

}

struct TimestampReplyStatus: Codable {
    let timestamp: Int64

    enum CodingKeys: String, CodingKey {
        case timestamp = "Timestamp"
    }
    
}
