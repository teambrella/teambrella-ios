//
//  PrivateChatUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PrivateChatUser {
    let json: JSON
    
    var id: String { return json["UserId"].stringValue }
    var avatar: String { return json["Avatar"].stringValue }
    var name: String { return json["Name"].stringValue }
    var text: String { return json["Text"].stringValue }
    var unreadCount: Int { return json["UnreadCount"].intValue }
    var minutesSinceLast: Int { return json["SinceLastMessageMinutes"].intValue }
}
