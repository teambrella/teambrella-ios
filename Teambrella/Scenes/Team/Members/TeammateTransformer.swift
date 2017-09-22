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
    let teammate: TeammateEntity
    
    var privateChatUser: PrivateChatUser? {
        let dict: [String: Any] = ["UserId": teammate.userID,
                                   "Avatar": teammate.avatar,
                                   "Name": teammate.name,
                                   "Text": teammate.extended?.topic.originalPostText ?? "",
                                   "UnreadCount": teammate.extended?.topic.unreadCount ?? 0,
                                   "SinceLastMessageMinutes": teammate.extended?.topic.minutesSinceLastPost ?? 0
                                   ]
        let json = JSON(dict)
        return PrivateChatUser(json: json)
    }
    
}
