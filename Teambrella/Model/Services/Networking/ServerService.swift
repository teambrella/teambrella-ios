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
        static let siteURL = "http://192.168.0.254"
        
    }
    
    static func askServer(for string: String,
                          parameters: [String: String]? = nil,
                          success: @escaping (JSON) -> Void,
                          failure: @escaping (Error) -> Void) {
        Alamofire.request(url(string: string),
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success:
                                if let value = response.result.value {
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
    
    private static func url(string: String) -> String {
        return Constant.siteURL + "/" + string
    }
    
}
