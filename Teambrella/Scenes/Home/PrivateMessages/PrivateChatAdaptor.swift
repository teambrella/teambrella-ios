//
//  PrivateChatAdaptor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PrivateChatAdaptor {
    let json: JSON
    
    /*
     "Data": {
     "Avatar": "/content/uploads/00000000-0000-0000-0000-000000000101/a.jpg",
     "Name": "Albert Einstein",
     "Messages": [
     {
     "Id": "83d00739-4531-4f09-8924-a7d900f41f5e",
     "UserId": "913b57fa-df84-40d0-90b1-a7cf009c502d",
     "LastUpdated": 636391829293567640,
     "Created": 636391829293567640,
     "Points": 0,
     "Text": "abc",
     "Images": null,
     "ImageRatios": null
     },
     ...
     ]
     }
    */
    var adaptedMessages: [ChatEntity] {
        let name = json["Name"].stringValue
        let avatar = json["Avatar"].stringValue
        let jsons = json["Messages"].arrayValue
        var messages: [ChatEntity] = []
        for item in jsons {
            var json = item
            let teammatePart = JSON(["Name": name,
                                     "Avatar": avatar])
            json["TeammatePart"] = teammatePart
            messages.append(ChatEntity(json: json))
        }
        return messages
    }
    
}
