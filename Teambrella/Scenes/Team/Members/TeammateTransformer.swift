//
//  TeammateTransformer.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TeammateTransformer {
    let teammate: TeammateEntity?
    let extendedTeammate: ExtendedTeammateEntity?
    
    var privateChatUser: PrivateChatUser? {
        var dict: [String: Any] = [:]
        if let teammate = teammate {
            dict = ["UserId": teammate.userID,
                    "Avatar": teammate.avatar,
                    "Name": teammate.name,
                    "Text": teammate.extended?.topic.originalPostText ?? "",
                    "UnreadCount": teammate.extended?.topic.unreadCount ?? 0,
                    "SinceLastMessageMinutes": teammate.extended?.topic.minutesSinceLastPost ?? 0
            ]
            
        } else if let extended = extendedTeammate {
            dict = ["UserId": extended.basic.id,
                    "Avatar": extended.basic.avatar,
                    "Name": extended.basic.name,
                    "Text": extended.topic.originalPostText,
                    "UnreadCount": extended.topic.unreadCount,
                    "SinceLastMessageMinutes": extended.topic.minutesSinceLastPost
            ]
        }
        let json = JSON(dict)
        return PrivateChatUser(json: json)
    }
    
}
