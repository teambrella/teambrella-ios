//
//  UniversalChatDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

class UniversalChatDatasource {
    var topic: Topic?
    
    var claim: EnhancedClaimEntity?
    var name: String? {
        didSet {
            
        }
    }
    
    var posts: [ChatEntity] = []
    var limit = 100
    var since: Int64 = 0
    var offset = 0
    var avatarSize = 64
    var commentAvatarSize = 32
    private(set) var isLoading = false
    private(set) var hasMore = true
    
    var onUpdate: (() -> Void)?
    
    var count: Int { return posts.count }
    
    func loadNext() {
        guard isLoading == false, hasMore == true else { return }
        
        isLoading = true
        let key = service.server.key
        
        var body: RequestBody?
        var request: TeambrellaRequest?
        if let claimID = claim?.id {
            body = RequestBody(key: key, payload: ["claimId": claimID,
                                                   "since": since,
                                                   "limit": limit,
                                                   "offset": offset,
                                                   "avatarSize": avatarSize,
                                                   "commentAvatarSize": commentAvatarSize])
            request = TeambrellaRequest(type: .claimChat, body: body, success: { [weak self] response in
                guard let me = self else { return }
                
                if case .claimChat(let lastRead, let chat, let basicInfo) = response {
                    print("claimChat got \(chat.count) messages")
                    me.posts.append(contentsOf: chat)
                    me.since = lastRead
                    me.offset += chat.count
                    me.onUpdate?()
                    if me.limit > chat.count {
                        me.hasMore = false
                    }
                    print(basicInfo)
                }
               me.isLoading = false
            })
        } else if topic != nil {
//            body = RequestBody(key: key, payload: ["claimId": claim.id,
//                                                   "since": since,
//                                                   "limit": limit,
//                                                   "offset": offset,
//                                                   "avatarSize": avatarSize,
//                                                   "commentAvatarSize": commentAvatarSize])
//            request = TeambrellaRequest(type: .claimChat, body: body, success: { [weak self] response in
//                guard let me = self else { return }
//
//                if case .claimChat(let json) = response {
//                    print(json)
//                    me.onUpdate?()
//                }
//            })
        }
        request?.start()
    }
    
    func send(text: String, completion: @escaping (Bool) -> Void) {
        var topicID: String?
        if let claim = claim {
            topicID = claim.topicID
        }
        
        let payload: [String: Any] = ["TopicId": topicID ?? "",
                                      "Text": text]
        let body = RequestBody(key: service.server.key, payload: payload)
        let request = TeambrellaRequest(type: .newPost, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            if case .newPost(let post) = response {
                me.posts.append(post)
                completion(true)
            } else {
                completion(false)
            }
            me.hasMore = true
        })
        request.start()
    }

}

struct ChatEntity {
    let json: JSON
    
    var userID: String { return json["UserId"].stringValue }
    var lastUpdated: Date { return Date(ticks: json["LastUpdated"].uInt64Value) }
    var id: String { return json["Id"].stringValue }
    var created: Date { return Date(ticks: json["Created"].uInt64Value) }
    var points: Int { return json["Points"].intValue }
    var text: String { return json["Text"].stringValue }
    var images: [String] { return json["Images"].arrayObject as? [String] ?? [] }
    var name: String { return json["TeammatePart"]["Name"].stringValue }
    var avatar: String { return json["TeammatePart"]["Avatar"].stringValue }
    var isMyProxy: Bool { return json["TeammatePart"]["IsMyProxy"].boolValue }
    var vote: Double { return json["TeammatePart"]["Vote"].doubleValue }
    
    init(json: JSON) {
        self.json = json
    }
    
    static func buildArray(from json: JSON) -> [ChatEntity] {
        guard let array = json.array else { return [] }
        
        return array.flatMap { ChatEntity(json: $0) }
    }
}
