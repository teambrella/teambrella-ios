//
//  ChatEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChatEntity {
    let json: JSON
    
    var userID: String { return json["UserId"].stringValue }
    var lastUpdated: Date { return Date(ticks: json["LastUpdated"].uInt64Value) }
    var id: String { return json["Id"].stringValue }
    var created: Date { return Date(ticks: json["Created"].uInt64Value) }
    var points: Int { return json["Points"].intValue }
    var text: String { return json["Text"].stringValue }
    var images: [String] { return json["Images"].arrayObject as? [String] ?? [] }
    
    var isMyProxy: Bool { return json["TeammatePart"]["IsMyProxy"].boolValue }
    var name: String { return json["TeammatePart"]["Name"].stringValue }
    var avatar: String { return json["TeammatePart"]["Avatar"].stringValue }
    var vote: Double { return json["TeammatePart"]["Vote"].doubleValue }
    
    init(json: JSON) {
        self.json = json
    }
    
    static func buildArray(from json: JSON) -> [ChatEntity] {
        guard let array = json.array else { return [] }
        
        return array.flatMap { ChatEntity(json: $0) }
    }
}
