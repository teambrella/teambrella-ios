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
import SwiftyJSON

class TimestampFetcher {
    func requestTimestamp(completion: @escaping (Int64, Error?) -> Void) {
        guard let url = URLBuilder().url(string: "me/GetTimestamp") else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseJSON { response in
            var timestamp: Int64 = 0
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let result = JSON(value)
                    timestamp = result["Status"]["Timestamp"].int64Value
                }
                completion(timestamp, nil)
            case .failure(let error):
                completion(0, error)
            }
        }
    }
    
}
