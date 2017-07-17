//
//  CosignerEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CosignerEntity {
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var avatar: String { return json["Avatar"].stringValue }
    var name: String { return json["Name"].stringValue }
    var userId: String { return json["UserId"].stringValue }
}
