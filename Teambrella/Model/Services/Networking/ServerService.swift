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

struct ServerService {
    struct Constant {
        static let siteURL = "http://surilla.com"//"http://192.168.0.254"
        static let fakePrivateKey = "Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
        
    }
    
    static func askServer(for string: String,
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
            if let string = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(string)
            }
        }
        Alamofire.request(request).responseJSON { response in
                            switch response.result {
                            case .success:
                                if let value = response.result.value {
                                    print(value)
                                    let result = JSON(value)
                                    success(result)
                                } else {
                                    let error = AmbrellaError.emptyReply
                                    failure(error)
                                }
                            case .failure(let error):
                                failure(error)
                            }
        }
    }
    
    private static func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
