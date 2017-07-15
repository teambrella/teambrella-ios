//
//  Session.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct Session {
    var currentTeam: TeamEntity?
    var teams: [TeamEntity] = []
    
    // TMP: my user properties
    var currentUserID: String?
    var currentUserName: String?
    var myAvatarString: String { return "me/avatar" }
    var myAvatarStringSmall: String { return myAvatarString + "/128" }
}
