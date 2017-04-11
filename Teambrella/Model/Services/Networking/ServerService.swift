//
//  ServerService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class ServerService {
    struct Constant {
        static let siteURL = "http://192.168.0.254" //"http://surilla.com"
        static let fakePrivateKey = "Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
        
    }
    
    private(set)var timestamp: Int64 = 0 {
        didSet {
            print("timestamp updated from \(oldValue) to \(timestamp)")
        }
    }
    
    init() {
        
    }
    
    func avatarURLstring(for string: String, width: CGFloat? = nil, crop rect: CGRect? = nil) -> String {
        var urlString = Constant.siteURL + string
        if let width = width {
            let rect = rect ?? CGRect(x: 0, y: 0, width: width, height: width)
            urlString += "?width=\(width)&crop=\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height)"
        }
        return urlString
    }
    
    func ask(for string: String,
             parameters: [String: String]? = nil,
             body: RequestBody? = nil,
             success: @escaping (JSON) -> Void,
             failure: @escaping (Error) -> Void) {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body, let data = try? JSONSerialization.data(withJSONObject: body.dictionary,
                                                                   options: []) {
            request.httpBody = data
            printAsString(data: data)
        }
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print(value)
                    let result = JSON(value)
                    let status = result["Status"]
                    self.timestamp = status["Timestamp"].int64Value
                    switch status["ResultCode"].intValue {
                    case 0:
                        success(result["Data"])
                    default:
                        let error = AmbrellaErrorFactory.error(with: status.rawValue as? [String: Any])
                        failure(error)
                    }
                } else {
                    let error = AmbrellaErrorFactory.emptyReplyError()
                    failure(error)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func printAsString(data: Data?) {
        guard let data = data else { return }
        
        if let string = try? JSONSerialization.jsonObject(with: data, options: []) {
            print(string)
        }
    }
    
    private func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
