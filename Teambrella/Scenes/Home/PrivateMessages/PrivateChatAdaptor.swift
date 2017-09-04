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
    
    var adaptedMessages: [ChatEntity] {
        let discussion = json["DiscussionPart"]
        let basic = json["BasicPart"]
        let name = basic["Name"].stringValue
        let avatar = basic["Avatar"].stringValue
        let jsons = discussion["Chat"].arrayValue
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
