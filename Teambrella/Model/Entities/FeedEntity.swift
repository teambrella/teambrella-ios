//
//  FeedEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FeedEntity {
    let json: JSON
    
    var amount: Double { return json["Amount"].doubleValue }
    var teamVote: Double { return json["TeamVote"].doubleValue }
    
}

/*
 "Amount": 194.99984025356469,
 "TeamVote": 0.975,
 "IsVoting": false,
 "PayProgress": 0.99999999999997291,
 "ItemType": 1,
 "ItemId": 4399,
 "ItemUserId": "00000000-0000-0000-0000-000000000248",
 "ItemDate": "2017-06-20 00:30:02",
 "SmallPhotoOrAvatar": "/ImageHandler.ashx?t=m&file=sm17291_1.jpg",
 "ModelOrName": "Charlie",
 "ChatTitle": null,
 "Text": "<p>Hey everyone, about a week ago Charlie was having troubles with his left eye, it went red. After a little while it seemed to clear up a bit, but I decided to take Charlie to the vet anyway. She said that she thought is was allergies but prescribed antibiotics and steroids. A vis...</p>\n",
 "UnreadCount": 0,
 "PosterCount": 5,
 "TopPosterAvatars": [
 "/content/uploads/56c7db00-30e2-493e-8c3c-a7a800084027/a.jpg?width=64&crop=0,0,64,64",
 "/content/uploads/00000000-0000-0000-0000-000000000201/a.jpg?width=64&crop=0,0,64,64",
 "/content/uploads/00000000-0000-0000-0000-000000000203/a.jpg?width=64&crop=0,0,64,64"
 */
